const API_BASE = '/api';

export async function apiRequest(path, { method = 'GET', body, token, query } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  let url = `${API_BASE}${path}`;
  if (query) {
    const params = new URLSearchParams(query);
    url += `?${params.toString()}`;
  }
  const res = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    let error = 'Request failed';
    try { const data = await res.json(); error = data.error || data.errors?.join(', ') || error; } catch {}
    throw new Error(error);
  }
  const contentType = res.headers.get('content-type') || '';
  if (contentType.includes('application/json')) return res.json();
  return null;
}

export const login = (email, password) => apiRequest('/login', { method: 'POST', body: { email, password } });
export const fetchBooks = (token, page=1, q) => {
  const query = { page };
  if (q && q.trim() !== '') query.q = q;
  return apiRequest('/books', { token, query });
};
export const createBorrowing = (token, book_id) => apiRequest('/borrowings', { method: 'POST', body: { borrowing: { book_id } }, token });
export const returnBorrowing = (token, id) => apiRequest(`/borrowings/${id}/return_book`, { method: 'POST', token });
export const fetchBorrowings = (token) => apiRequest('/borrowings', { token });
export const fetchDashboardSummary = (token) => apiRequest('/dashboard/summary', { token });
export const createBook = (token, book) => apiRequest('/books', { method: 'POST', body: { book }, token });
export const deleteBook = (token, id) => apiRequest(`/books/${id}`, { method: 'DELETE', token });
export const updateBook = (token, id, book) => apiRequest(`/books/${id}`, { method: 'PUT', body: { book }, token });
