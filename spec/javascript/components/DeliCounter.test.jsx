import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import DeliCounter from 'components/app/DeliCounter';

describe('DeliCounter', () => {
  it('reports how many people are ahead, excluding the one being served', () => {
    render(<DeliCounter ticket={10} nowServing={5} />);

    expect(screen.getByText('There are 4 people ahead of you in line.')).toBeInTheDocument();
  });

  it('uses the singular when exactly one person is ahead', () => {
    render(<DeliCounter ticket={7} nowServing={5} />);

    expect(screen.getByText('There is 1 person ahead of you in line.')).toBeInTheDocument();
  });

  it('uses the plural when nobody is ahead', () => {
    render(<DeliCounter ticket={6} nowServing={5} />);

    expect(screen.getByText('There are 0 people ahead of you in line.')).toBeInTheDocument();
  });

  it('treats a missing nowServing as position zero', () => {
    render(<DeliCounter ticket={3} />);

    expect(screen.getByText('There are 2 people ahead of you in line.')).toBeInTheDocument();
  });

  it('warns against refreshing', () => {
    render(<DeliCounter ticket={10} nowServing={5} />);

    expect(
      screen.getByText('Please do not refresh the page, or you will lose your place in line.'),
    ).toBeInTheDocument();
  });
});
