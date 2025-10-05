import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, Link, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from '../components/AuthContext';
import LoginPage from '../pages/LoginPage';
import BooksPage from '../pages/BooksPage';
import BorrowingsPage from '../pages/BorrowingsPage';
import DashboardPage from '../pages/DashboardPage';

function Nav() {
  const { isAuthenticated, logout, role } = useAuth();
  return (
    <nav style={{ display:'flex', gap:'1rem', padding:'0.5rem', background:'#eee', alignItems:'center' }}>
      <Link to="/">Dashboard</Link>
  <Link to="/books">Books</Link>
  <Link to="/borrowings">Borrowings</Link>
      {role === 'admin' && <span style={{ fontSize:12, background:'#333', color:'#fff', padding:'2px 6px', borderRadius:4 }}>ADMIN</span>}
      {role === 'librarian' && <span style={{ fontSize:12, background:'#0066cc', color:'#fff', padding:'2px 6px', borderRadius:4 }}>LIBRARIAN</span>}
      <div style={{ marginLeft:'auto', display:'flex', gap:'0.75rem' }}>
        {!isAuthenticated && <Link to="/login">Login</Link>}
        {isAuthenticated && <button onClick={logout}>Logout</button>}
      </div>
    </nav>
  );
}

function Protected({ children }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return children;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Nav />
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<Protected><DashboardPage /></Protected>} />
          <Route path="/books" element={<Protected><BooksPage /></Protected>} />
          <Route path="/borrowings" element={<Protected><BorrowingsPage /></Protected>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

const root = document.getElementById('root');
if (root) createRoot(root).render(<App />);
