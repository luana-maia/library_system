import React, { useState } from 'react';
import { useAuth } from '../components/AuthContext';

export default function LoginPage() {
  const { login, loading, error, isAuthenticated } = useAuth();
  const [email, setEmail] = useState('student@example.com');
  const [password, setPassword] = useState('password');

  const handleSubmit = (e) => {
    e.preventDefault();
    login(email, password);
  };

  if (isAuthenticated) return <p>Logged in.</p>;

  return (
    <div style={{ maxWidth: 320, margin: '2rem auto', fontFamily: 'sans-serif' }}>
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        <label>Email<br/><input value={email} onChange={e=>setEmail(e.target.value)} /></label><br/>
        <label>Password<br/><input type='password' value={password} onChange={e=>setPassword(e.target.value)} /></label><br/>
        <button disabled={loading}>{loading ? '...' : 'Login'}</button>
      </form>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
}
