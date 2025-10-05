import React, { useEffect, useState } from 'react';
import { fetchDashboardSummary } from '../api/client';
import { useAuth } from '../components/AuthContext';

export default function DashboardPage() {
  const { token } = useAuth();
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!token) return;
    (async () => {
      try {
        setSummary(await fetchDashboardSummary(token));
      } catch (e) { setError(e.message); }
    })();
  }, [token]);

  if (!token) return <p>Please login.</p>;
  if (!summary) return <p>Loading...</p>;

  return (
    <div style={{ padding: '1rem' }}>
      <h2>Dashboard</h2>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <div style={{ display:'flex', gap:'1rem', flexWrap:'wrap' }}>
        <Stat label='Books' value={summary.books_count} />
        <Stat label='Users' value={summary.users_count} />
        <Stat label='Active Borrowings' value={summary.active_borrowings} />
        <Stat label='Overdue Borrowings' value={summary.overdue_borrowings} highlight={summary.overdue_borrowings>0} />
        <Stat label='Available Books' value={summary.available_books} />
      </div>
    </div>
  );
}

function Stat({ label, value, highlight }) {
  return (
    <div style={{ border:'1px solid #ddd', padding:'0.75rem 1rem', borderRadius:6, background: highlight ? '#ffe5e5' : '#fafafa', minWidth:140 }}>
      <div style={{ fontSize:12, textTransform:'uppercase', color:'#666' }}>{label}</div>
      <div style={{ fontSize:24, fontWeight:600 }}>{value}</div>
    </div>
  );
}
