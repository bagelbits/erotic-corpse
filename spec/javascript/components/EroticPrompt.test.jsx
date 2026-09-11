import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import EroticPrompt from 'components/app/EroticPrompt';

// howler drives the Web Audio API, which jsdom does not implement.
vi.mock('react-howler', () => ({ default: () => <div data-testid="bell" /> }));

const LAST_PROMPT = { id: 7, prompt: 'She opened the door.' };

const respondWith = (overrides = {}) => {
  const routes = {
    '/prompts/last': LAST_PROMPT,
    '/deli_counter/heartbeat': {},
    '/prompts/story': {
      full_story: [{ prompt: 'She opened the door.' }, { prompt: 'He waited.' }],
    },
    '/prompts': {},
    ...overrides,
  };
  global.fetch = vi.fn((url) => {
    const match = Object.keys(routes)
      .sort((a, b) => b.length - a.length)
      .find((route) => String(url).includes(route));
    if (!match) throw new Error(`unexpected fetch: ${url}`);
    const body = routes[match];
    if (body instanceof Error) return Promise.reject(body);
    return Promise.resolve({ json: () => Promise.resolve(body) });
  });
};

const renderPrompt = () => render(<EroticPrompt ticket={10} token="abc" />);

describe('EroticPrompt', () => {
  beforeEach(() => {
    respondWith();
    vi.spyOn(window, 'alert').mockImplementation(() => {});
  });

  it('shows the previous prompt to build on', async () => {
    renderPrompt();

    expect(await screen.findByText('She opened the door.')).toBeInTheDocument();
    expect(screen.getByText('What happens next?')).toBeInTheDocument();
  });

  it('fetches the prompt once, not on every re-render', async () => {
    renderPrompt();
    await screen.findByText('She opened the door.');

    await userEvent.type(await screen.findByRole('textbox'), 'typing re-renders this');

    const fetches = global.fetch.mock.calls.filter(([url]) =>
      String(url).includes('/prompts/last'),
    );
    expect(fetches).toHaveLength(1);
  });

  it('reports failure when the prompt cannot be fetched', async () => {
    respondWith({ '/prompts/last': new Error('boom') });
    renderPrompt();

    expect(await screen.findByText('Something went terribly wrong.')).toBeInTheDocument();
  });

  it('starts the character counter at the 280 character limit', async () => {
    renderPrompt();

    expect(await screen.findByText('280')).toBeInTheDocument();
  });

  it('counts down the characters remaining as the visitor types', async () => {
    renderPrompt();
    const box = await screen.findByRole('textbox');

    await userEvent.type(box, 'Hello');

    expect(screen.getByText('275')).toBeInTheDocument();
  });

  it('caps the textarea at the character limit', async () => {
    renderPrompt();

    expect(await screen.findByRole('textbox')).toHaveAttribute('maxlength', '280');
  });

  it('submits the new prompt against the previous one', async () => {
    renderPrompt();
    await userEvent.type(await screen.findByRole('textbox'), 'He waited.');

    await userEvent.click(screen.getByRole('button', { name: 'Submit!' }));

    await waitFor(() => {
      const post = global.fetch.mock.calls.find(
        ([url, o]) => url === '/prompts' && o?.method === 'post',
      );
      expect(JSON.parse(post[1].body)).toMatchObject({
        prompt: 'He waited.',
        previous_prompt_id: 7,
        ticket: 10,
        token: 'abc',
      });
    });
  });

  it('ignores a submission that is only whitespace', async () => {
    renderPrompt();
    await userEvent.type(await screen.findByRole('textbox'), '   ');

    await userEvent.click(screen.getByRole('button', { name: 'Submit!' }));

    expect(
      global.fetch.mock.calls.some(([url, o]) => url === '/prompts' && o?.method === 'post'),
    ).toBe(false);
    expect(screen.getByRole('button', { name: 'Submit!' })).not.toBeDisabled();
  });

  it('thanks the visitor and shows the assembled story after submitting', async () => {
    renderPrompt();
    await userEvent.type(await screen.findByRole('textbox'), 'He waited.');

    await userEvent.click(screen.getByRole('button', { name: 'Submit!' }));

    expect(await screen.findByText('Thank you for playing~!')).toBeInTheDocument();
    expect(await screen.findByText('She opened the door. He waited.')).toBeInTheDocument();
  });

  it('asks for confirmation before reporting', async () => {
    renderPrompt();

    await userEvent.click(await screen.findByRole('button', { name: 'Report!' }));

    expect(screen.getByText('Are you sure you want to report this?')).toBeInTheDocument();
  });

  it('reports the prompt being displayed', async () => {
    renderPrompt();
    await userEvent.click(await screen.findByRole('button', { name: 'Report!' }));

    await userEvent.click(screen.getByRole('button', { name: 'Report' }));

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        '/prompts/7/report',
        expect.objectContaining({ method: 'post' }),
      );
    });
  });

  it('surfaces the server message when a report is refused', async () => {
    respondWith({ '/prompts/7/report': { success: false, error: 'Nope.' } });
    renderPrompt();
    await userEvent.click(await screen.findByRole('button', { name: 'Report!' }));

    await userEvent.click(screen.getByRole('button', { name: 'Report' }));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith('Nope.'));
  });

  it('heartbeats on an interval rather than on mount', async () => {
    vi.useFakeTimers();
    try {
      renderPrompt();
      await act(async () => {
        await vi.advanceTimersByTimeAsync(0);
      });

      const beat = () =>
        global.fetch.mock.calls.filter(([url]) => url === '/deli_counter/heartbeat').length;
      expect(beat()).toBe(0);

      await act(async () => {
        await vi.advanceTimersByTimeAsync(4000);
      });
      expect(beat()).toBe(1);

      await act(async () => {
        await vi.advanceTimersByTimeAsync(4000);
      });
      expect(beat()).toBe(2);
    } finally {
      vi.useRealTimers();
    }
  });
});
