import { screen, within } from '@testing-library/react';

import Show from '@/pages/Poll/Show';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

const poll = {
  id: 'poll_123',
  name: 'Team Offsite',
  description: 'Planning our annual team offsite event',
  organizer_name: 'Jane Doe',
  created_at: '2030-05-15T10:00:00Z',
  end_voting_at: '2030-06-01T23:59:59Z',
  path: '/poll_123',
  vote_path: '/poll_123/vote',
  edit_vote_path: '/poll_123/votes/edit',
};

const options = [
  { id: 'popt_1', start: '2030-06-15T00:00:00Z', duration_minutes: 1440, counts: { yes: 2, maybe: 0, no: 0 } },
  { id: 'popt_2', start: '2030-06-16T00:00:00Z', duration_minutes: 1440, counts: { yes: 1, maybe: 1, no: 0 } },
];

const participants = [
  { id: 'part_1', name: 'Alice Smith', you: false, responses: { popt_1: 'yes' as const, popt_2: 'maybe' as const } },
  { id: 'part_2', name: 'Bob Johnson', you: true, responses: { popt_1: 'yes' as const, popt_2: 'yes' as const } },
];

describe('Poll Show page', () => {
  test('renders the poll details', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={participants} best_option_ids={['popt_1']} you_voted={false} />
    );

    expect(screen.getByRole('heading', { name: 'Team Offsite' })).toBeInTheDocument();
    expect(screen.getByText('Planning our annual team offsite event')).toBeInTheDocument();
    expect(screen.getByText('Organized by Jane Doe')).toBeInTheDocument();
  });

  test('shows the best date with its counts', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={participants} best_option_ids={['popt_1']} you_voted={false} />
    );

    const best = screen.getAllByTestId('best-option');
    expect(best).toHaveLength(1);
    expect(best[0]).toHaveTextContent('Saturday, June 15, 2030');
    expect(best[0]).toHaveTextContent('2 Yes');
  });

  test('shows every participant with their answers and the totals', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={participants} best_option_ids={['popt_1']} you_voted={true} />
    );

    const aliceRow = screen.getByText('Alice Smith').closest('tr')!;
    expect(within(aliceRow).getByLabelText('Yes')).toBeInTheDocument();
    expect(within(aliceRow).getByLabelText('Maybe')).toBeInTheDocument();

    expect(screen.getByText('(you)')).toBeInTheDocument();
    expect(screen.getByTestId('total-popt_1')).toHaveTextContent('2 / 0');
    expect(screen.getByTestId('total-popt_2')).toHaveTextContent('1 / 1');
  });

  test('links to the vote form or to your answers', () => {
    const { unmount } = renderWithInertia(
      <Show poll={poll} options={options} participants={[]} best_option_ids={[]} you_voted={false} />
    );
    expect(screen.getByRole('link', { name: 'Add your answers' })).toHaveAttribute('href', '/poll_123/vote');
    unmount();

    renderWithInertia(
      <Show poll={poll} options={options} participants={participants} best_option_ids={[]} you_voted={true} />
    );
    expect(screen.getByRole('link', { name: 'Edit your answers' })).toHaveAttribute('href', '/poll_123/votes/edit');
  });

  test('shows empty states before anyone answers', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={[]} best_option_ids={[]} you_voted={false} />
    );

    expect(screen.getByText('No one is available yet.')).toBeInTheDocument();
    expect(screen.getByText('No answers yet. Be the first!')).toBeInTheDocument();
  });

  test('shows all-day dates on the same calendar day in every time zone', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={participants} best_option_ids={[]} you_voted={false} />
    );

    expect(screen.getByText('Jun 15')).toBeInTheDocument();
    expect(screen.getByText('Jun 16')).toBeInTheDocument();
  });

  test('shows a Manage link only to the organizer', () => {
    const { unmount } = renderWithInertia(
      <Show poll={poll} options={options} participants={[]} best_option_ids={[]} you_voted={false} />
    );
    expect(screen.queryByRole('link', { name: 'Manage poll' })).not.toBeInTheDocument();
    unmount();

    renderWithInertia(
      <Show poll={poll} options={options} participants={[]} best_option_ids={[]} you_voted={false} admin_path="/poll_123/admin/secret" />
    );
    expect(screen.getByRole('link', { name: 'Manage poll' })).toHaveAttribute('href', '/poll_123/admin/secret');
  });

  test('has a Share poll button', () => {
    renderWithInertia(
      <Show poll={poll} options={options} participants={[]} best_option_ids={[]} you_voted={false} />
    );

    expect(screen.getByRole('button', { name: /share poll/i })).toBeInTheDocument();
  });
});
