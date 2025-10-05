import React, { useEffect, useState, useMemo } from 'react';
import { fetchBorrowings, returnBorrowing } from '../api/client';
import { useAuth } from '../components/AuthContext';

export default function BorrowingsPage() {
  const { token, role } = useAuth();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [q, setQ] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [onlyActive, setOnlyActive] = useState(false);

  async function load() {
    if (!token) return; setLoading(true); setError(null);
    try {
      const data = await fetchBorrowings(token);
      setItems(Array.isArray(data) ? data : (data.borrowings || data.data || []));
    } catch (e) { setError(e.message); }
    finally { setLoading(false); }
  }

  useEffect(()=>{ load(); /* eslint-disable-next-line */ }, [token]);

  const doReturn = async (id) => {
    try { await returnBorrowing(token, id); await load(); } catch (e) { setError(e.message); }
  };

  const filtered = useMemo(()=>{
    let list = items;
    if (q.trim()) {
      const term = q.toLowerCase();
      list = list.filter(b => (b.book?.title || '').toLowerCase().includes(term));
    }
    if (statusFilter !== 'all') list = list.filter(b => b.status === statusFilter);
    if (onlyActive) list = list.filter(b => !b.returned_at);
    return list;
  }, [items, q, statusFilter, onlyActive]);

  return (
    <div style={{ padding:'1rem', fontFamily:'sans-serif' }}>
      <h2>Borrowings</h2>
      {error && <p style={{ color:'red' }}>{error}</p>}
      {loading && <p>Loading...</p>}
      <div style={{ display:'flex', gap:'0.5rem', flexWrap:'wrap', marginBottom:'0.75rem' }}>
        <input placeholder='Search title' value={q} onChange={e=>setQ(e.target.value)} />
        <select value={statusFilter} onChange={e=>setStatusFilter(e.target.value)}>
          <option value='all'>All statuses</option>
          <option value='borrowed'>Borrowed</option>
          <option value='overdue'>Overdue</option>
          <option value='returned'>Returned</option>
        </select>
        <label style={{ display:'flex', alignItems:'center', gap:4 }}>
          <input type='checkbox' checked={onlyActive} onChange={e=>setOnlyActive(e.target.checked)} /> Only active
        </label>
        <button onClick={()=>{ setQ(''); setStatusFilter('all'); setOnlyActive(false); }}>Reset</button>
      </div>
      <table style={{ borderCollapse:'collapse', width:'100%' }}>
        <thead>
          <tr style={{ background:'#f2f2f2' }}>
            <th style={th}>Book</th>
            <th style={th}>Student</th>
            <th style={th}>Borrowed</th>
            <th style={th}>Due</th>
            <th style={th}>Status</th>
            <th style={th}>Elapsed (d)</th>
            <th style={th}>Remaining (d)</th>
            <th style={th}>Action</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map(b => {
            const overdue = b.status === 'overdue' || (b.due_at && !b.returned_at && new Date(b.due_at) < new Date());
            return (
              <tr key={b.id} style={{ background: overdue ? '#ffe5e5' : 'white' }}>
                <td style={td}>{b.book?.title || b.book_id}</td>
                <td style={td}>{b.user?.name || b.user_id}</td>
                <td style={td}>{b.borrowed_at ? new Date(b.borrowed_at).toLocaleDateString() : '—'}</td>
                <td style={td}>{b.due_at ? new Date(b.due_at).toLocaleDateString() : '—'}</td>
                <td style={td}>{overdue ? 'Overdue' : b.status}</td>
                <td style={td}>{b.borrow_duration_days}</td>
                <td style={td}>{b.returned_at ? 0 : b.days_remaining}</td>
                <td style={td}>
                  {(b.status === 'borrowed' || b.status === 'overdue') && !b.returned_at ? (
                    <button onClick={()=>doReturn(b.id)}>Mark Return</button>
                  ) : '—'}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

const th = { textAlign:'left', borderBottom:'1px solid #ccc', padding:'6px' };
const td = { borderBottom:'1px solid #eee', padding:'6px' };
