import React, { createContext, useState, useContext, useEffect } from 'react';
import { login as apiLogin } from '../api/client';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try { return JSON.parse(localStorage.getItem('ls_user')) || null; } catch { return null; }
  });
  const [token, setToken] = useState(() => localStorage.getItem('ls_token'));
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const login = async (email, password) => {
    setLoading(true); setError(null);
    try {
      const data = await apiLogin(email, password);
  setToken(data.token);
  setUser(data.user);
  localStorage.setItem('ls_token', data.token);
  localStorage.setItem('ls_user', JSON.stringify(data.user));
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const logout = () => { setUser(null); setToken(null); localStorage.removeItem('ls_token'); localStorage.removeItem('ls_user'); };

  const role = user?.role;
  const value = { user, token, role, loading, error, login, logout, isAuthenticated: !!token };
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() { return useContext(AuthContext); }
