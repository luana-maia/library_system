import React, { useEffect, useState } from 'react';
import { fetchBooks, createBorrowing, fetchBorrowings, returnBorrowing, createBook, deleteBook, updateBook } from '../api/client';
import { useAuth } from '../components/AuthContext';

export default function BooksPage() {
  const { token, role } = useAuth();
  const [books, setBooks] = useState([]);
  const [meta, setMeta] = useState(null);
  const [page, setPage] = useState(1);
  const [borrowings, setBorrowings] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [newBook, setNewBook] = useState({ title:'', author:'', isbn:'', genre:'', total_copies:1, available_copies:1 });
  const [editingId, setEditingId] = useState(null);
  const [editData, setEditData] = useState({ title:'', author:'', isbn:'', genre:'', total_copies:1, available_copies:1 });
  const [query, setQuery] = useState('');
  const [debounced, setDebounced] = useState('');

  useEffect(() => {
    const h = setTimeout(()=> setDebounced(query), 400);
    return () => clearTimeout(h);
  }, [query]);

  async function load() {
    if (!token) return;
    setLoading(true); setError(null);
    try {
      const data = await fetchBooks(token, page, debounced);
      if (Array.isArray(data)) {
        setBooks(data);
        setMeta(null);
      } else {
        const collection = data.books || data.data || data.collection || [];
        setBooks(collection);
        setMeta(data.meta || null);
      }
      setBorrowings(await fetchBorrowings(token));
    } catch (e) { setError(e.message); }
    finally { setLoading(false); }
  }

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [token, page, debounced]);

  const borrowedMap = new Map(borrowings.filter(b=>!b.returned_at).map(b => [b.book_id, b]));

  const borrow = async (bookId) => {
    try { await createBorrowing(token, bookId); await load(); } catch (e) { setError(e.message); }
  };

  const doReturn = async (borrowingId) => {
    try { await returnBorrowing(token, borrowingId); await load(); } catch (e) { setError(e.message); }
  };

  const addBook = async (e) => {
    e.preventDefault();
    try {
  await createBook(token, { ...newBook, total_copies: Number(newBook.total_copies), available_copies: Number(newBook.available_copies) });
  setNewBook({ title:'', author:'', isbn:'', genre:'', total_copies:1, available_copies:1 });
      await load();
    } catch (e2) { setError(e2.message); }
  };

  const removeBook = async (id) => {
    if (!confirm('Excluir este livro?')) return;
    try { await deleteBook(token, id); await load(); } catch (e) { setError(e.message); }
  };

  const startEdit = (book) => {
    setEditingId(book.id);
  setEditData({ title: book.title, author: book.author, isbn: book.isbn, genre: book.genre || '', total_copies: book.total_copies, available_copies: book.available_copies });
  };

  const cancelEdit = () => {
    setEditingId(null);
  };

  const submitEdit = async (e) => {
    e.preventDefault();
    try {
  await updateBook(token, editingId, { ...editData, total_copies: Number(editData.total_copies), available_copies: Number(editData.available_copies) });
      setEditingId(null);
      await load();
    } catch (e2) { setError(e2.message); }
  };

  if (!token) return <p>Please login.</p>;

  return (
    <div style={{ padding: '1rem', fontFamily:'sans-serif' }}>
      <h2>Books</h2>
      <div style={{ margin:'0 0 1rem', display:'flex', gap:'0.5rem', alignItems:'center' }}>
        <input
          style={{ flex:'1', padding:'4px 6px' }}
          placeholder='Search by title, author, or genre'
          value={query}
          onChange={e=>{ setPage(1); setQuery(e.target.value); }}
        />
        {debounced && <button onClick={()=>{ setQuery(''); setDebounced(''); }}>Clear</button>}
      </div>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {loading && <p>Loading...</p>}
  {role === 'librarian' && (
        <form onSubmit={addBook} style={{ marginBottom:'1rem', display:'flex', flexWrap:'wrap', gap:'0.5rem' }}>
          <input required placeholder='Title' value={newBook.title} onChange={e=>setNewBook({...newBook,title:e.target.value})} />
          <input required placeholder='Author' value={newBook.author} onChange={e=>setNewBook({...newBook,author:e.target.value})} />
          <input required placeholder='ISBN' value={newBook.isbn} onChange={e=>setNewBook({...newBook,isbn:e.target.value})} />
          <input placeholder='Genre' value={newBook.genre} onChange={e=>setNewBook({...newBook,genre:e.target.value})} />
          <label style={{ display:'flex', flexDirection:'column', fontSize:12 }}>
            Total
            <input
              type='number'
              min='1'
              placeholder='Total copies'
              value={newBook.total_copies}
              onChange={e=>{
                const total = e.target.value; let avail = newBook.available_copies;
                if (Number(avail) > Number(total)) avail = total; 
                setNewBook({...newBook,total_copies: total, available_copies: avail});
              }}
            />
          </label>
          <label style={{ display:'flex', flexDirection:'column', fontSize:12 }}>
            Available
            <input
              type='number'
              min='0'
              placeholder='Available copies'
              value={newBook.available_copies}
              onChange={e=>{
                const val = e.target.value; if (Number(val) <= Number(newBook.total_copies)) setNewBook({...newBook, available_copies: val}); }}
            />
          </label>
          <button>Add Book</button>
        </form>
      )}
      <div style={{ overflowX:'auto' }}>
        <table style={{ borderCollapse:'collapse', width:'100%' }}>
          <thead>
            <tr style={{ background:'#f2f2f2' }}>
              <th style={th}>Title</th>
              <th style={th}>Author</th>
              <th style={th}>ISBN</th>
              <th style={th}>Genre</th>
              <th style={th}>Total</th>
              <th style={th}>Available</th>
              {role !== 'librarian' && <th style={th}>Status</th>}
              {role !== 'librarian' && <th style={th}>Action</th>}
              {role === 'librarian' && <th style={th}>Manage</th>}
            </tr>
          </thead>
          <tbody>
            {books.map(b => {
              const borrowing = borrowedMap.get(b.id);
              const isBorrowed = !!borrowing;
              const due = borrowing?.due_at ? new Date(borrowing.due_at) : null;
              const overdue = borrowing && borrowing.status !== 'returned' && due && due < new Date();
              return (
                <tr key={b.id} style={{ background: overdue ? '#ffe5e5' : 'white' }}>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input value={editData.title} onChange={e=>setEditData({...editData,title:e.target.value})} />
                    ) : b.title}
                  </td>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input value={editData.author} onChange={e=>setEditData({...editData,author:e.target.value})} />
                    ) : b.author}
                  </td>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input value={editData.isbn} onChange={e=>setEditData({...editData,isbn:e.target.value})} />
                    ) : b.isbn}
                  </td>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input value={editData.genre} onChange={e=>setEditData({...editData,genre:e.target.value})} />
                    ) : (b.genre || '—')}
                  </td>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input type='number' min='1' value={editData.total_copies} onChange={e=>{
                        const total = e.target.value; let avail = editData.available_copies; if (Number(avail) > Number(total)) avail = total; setEditData({...editData,total_copies: total, available_copies: avail}); }} style={{ width:60 }} />
                    ) : b.total_copies}
                  </td>
                  <td style={td}>
                    {editingId === b.id ? (
                      <input type='number' min='0' value={editData.available_copies} onChange={e=>{
                        const val = e.target.value; if (Number(val) <= Number(editData.total_copies)) setEditData({...editData, available_copies: val}); }} style={{ width:60 }} />
                    ) : b.available_copies}
                  </td>
                  {role !== 'librarian' && (
                    <td style={td}>
                      {borrowing ? (
                        overdue ? `Overdue (${borrowing.days_remaining || 0}d late)` :
                          `Borrowed ${borrowing.borrow_duration_days}d / due in ${borrowing.days_remaining}d`
                      ) : '—'}
                    </td>
                  )}
                  {role !== 'librarian' && (
                    <td style={td}>
                      {isBorrowed ? (
                        (borrowing.status === 'borrowed' || borrowing.status === 'overdue') ? <button onClick={() => doReturn(borrowing.id)}>Return</button> : '—'
                      ) : (
                        b.available_copies > 0 ? <button onClick={() => borrow(b.id)}>Borrow</button> : 'Out'
                      )}
                    </td>
                  )}
                  {role === 'librarian' && (
                    <td style={td}>
                      {editingId === b.id ? (
                        <form onSubmit={submitEdit} style={{ display:'flex', gap:4 }}>
                          <button type='submit'>Save</button>
                          <button type='button' onClick={cancelEdit}>Cancel</button>
                        </form>
                      ) : (
                        <div style={{ display:'flex', gap:4 }}>
                          <button onClick={() => startEdit(b)}>Edit</button>
                          <button onClick={() => removeBook(b.id)} disabled={isBorrowed}>Delete</button>
                        </div>
                      )}
                    </td>
                  )}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {meta && (
        <div style={{ marginTop:'0.75rem', display:'flex', gap:'0.5rem', alignItems:'center' }}>
          <button disabled={page <= 1} onClick={()=>setPage(p=>p-1)}>Prev</button>
          <span>Page {meta.page} / {meta.total_pages}</span>
          <button disabled={meta.page >= meta.total_pages} onClick={()=>setPage(p=>p+1)}>Next</button>
        </div>
      )}
    </div>
  );
}

const th = { textAlign:'left', borderBottom:'1px solid #ccc', padding:'6px' };
const td = { borderBottom:'1px solid #eee', padding:'6px' };
