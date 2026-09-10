import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import App from 'components/App';

// EroticPrompt does its own fetching and audio; its behaviour is covered by its own spec.
vi.mock('components/app/EroticPrompt', () => ({
  default: ({ ticket, token }) => <div data-testid="erotic-prompt">{`${ticket}/${token}`}</div>,
}));

const respondWith = (routes) => {
  global.fetch = vi.fn((url) => {
    const match = Object.keys(routes).find((route) => String(url).includes(route));
    if (!match) throw new Error(`unexpected fetch: ${url}`);
    const body = routes[match];
    if (body instanceof Error) return Promise.reject(body);
    return Promise.resolve({ json: () => Promise.resolve(body) });
  });
};

const consent = async () => {
  await userEvent.click(screen.getByRole('button', { name: 'Hell yes!' }));
};

describe('App', () => {
  beforeEach(() => {
    respondWith({});
  });

  it('asks for consent before fetching anything', () => {
    render(<App />);

    expect(screen.getByText(/graphic sexual nature/)).toBeInTheDocument();
    expect(global.fetch).not.toHaveBeenCalled();
  });

  it('always offers the radio stream', () => {
    render(<App />);

    expect(screen.getByText(/Radio KTSK/)).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Welcome to Erotic Corpse' })).toBeInTheDocument();
  });

  it('takes a ticket once consent is given', async () => {
    respondWith({
      '/deli_counter/ticket': { ticket: 10, token: 'abc' },
      '/deli_counter/now_serving': { ticket: 5 },
    });
    render(<App />);

    await consent();

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        '/deli_counter/ticket',
        expect.objectContaining({ method: 'post' }),
      );
    });
  });

  it('sends the CSRF token from the page when taking a ticket', async () => {
    respondWith({
      '/deli_counter/ticket': { ticket: 10, token: 'abc' },
      '/deli_counter/now_serving': { ticket: 5 },
    });
    render(<App />);

    await consent();

    await waitFor(() => {
      const [, options] = global.fetch.mock.calls[0];
      expect(options.headers['X-CSRF-Token']).toBe('test-csrf-token');
    });
  });

  it('queues the visitor while others are ahead', async () => {
    respondWith({
      '/deli_counter/ticket': { ticket: 10, token: 'abc' },
      '/deli_counter/now_serving': { ticket: 5 },
    });
    render(<App />);

    await consent();

    expect(await screen.findByText('There are 4 people ahead of you in line.')).toBeInTheDocument();
  });

  it('hands over to the prompt once the ticket is being served', async () => {
    respondWith({
      '/deli_counter/ticket': { ticket: 10, token: 'abc' },
      '/deli_counter/now_serving': { ticket: 10 },
    });
    render(<App />);

    await consent();

    expect(await screen.findByTestId('erotic-prompt')).toHaveTextContent('10/abc');
  });

  it('reports failure when the ticket cannot be fetched', async () => {
    respondWith({
      '/deli_counter/ticket': new Error('boom'),
      '/deli_counter/now_serving': { ticket: 1 },
    });
    render(<App />);

    await consent();

    expect(await screen.findByText('Something went terribly wrong.')).toBeInTheDocument();
  });
});
