import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ConsentPage from 'components/app/ConsentPage';

describe('ConsentPage', () => {
  beforeEach(() => {
    // jsdom refuses real navigation, so the bail-out button needs a writable location.
    Object.defineProperty(window, 'location', { value: { href: '' }, writable: true });
  });

  it('warns about the graphic content before consent is given', () => {
    render(<ConsentPage setConsent={vi.fn()} />);

    expect(screen.getByText(/graphic sexual nature/)).toBeInTheDocument();
    expect(screen.getByText(/agree not to engage/)).toBeInTheDocument();
  });

  it('records consent when the visitor accepts', async () => {
    const setConsent = vi.fn();
    render(<ConsentPage setConsent={setConsent} />);

    await userEvent.click(screen.getByRole('button', { name: 'Hell yes!' }));

    expect(setConsent).toHaveBeenCalledWith(true);
  });

  it('navigates away instead of consenting when the visitor declines', async () => {
    const setConsent = vi.fn();
    render(<ConsentPage setConsent={setConsent} />);

    await userEvent.click(screen.getByRole('button', { name: 'Not today, Satan' }));

    expect(window.location.href).toBe('about:blank');
    expect(setConsent).not.toHaveBeenCalled();
  });

  it('credits the sound and the authors', () => {
    render(<ConsentPage setConsent={vi.fn()} />);

    expect(screen.getByText('Created by Chris Ward')).toBeInTheDocument();
    expect(screen.getByText(/InspectorJ/)).toBeInTheDocument();
  });
});
