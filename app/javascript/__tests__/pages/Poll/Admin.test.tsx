import { screen } from '@testing-library/react';

import Admin from '@/pages/Poll/Admin';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

const poll = {
  id: 'poll_123',
  name: 'Board game night',
  description: '',
  organizer_name: 'Carol',
  end_voting_at: '2030-01-10T23:59:59Z',
  path: '/poll_123',
  options: [],
};

const links = {
  public: 'https://sroodle.test/poll_123',
  vote: 'https://sroodle.test/poll_123/vote',
  admin: 'https://sroodle.test/poll_123/admin/secret',
};

describe('Poll Admin page', () => {
  test('shows the public poll link and the private admin link', () => {
    renderWithInertia(<Admin poll={poll} links={links} participants_count={0} />);

    expect(screen.getByText('Board game night')).toBeInTheDocument();
    expect(screen.getByText(links.public)).toBeInTheDocument();
    expect(screen.getByText(links.admin)).toBeInTheDocument();
    expect(screen.getByText(/don't share it/)).toBeInTheDocument();
  });

  test('shows how many people answered', () => {
    renderWithInertia(<Admin poll={poll} links={links} participants_count={1} />);
    expect(screen.getByText('1 person has answered')).toBeInTheDocument();
  });

  test('shows a flash notice from the server', () => {
    renderWithInertia(<Admin poll={poll} links={links} participants_count={3} />, {
      inertiaProps: { flash: { notice: 'Poll created. Save the admin link below.' } },
    });

    expect(screen.getByRole('status')).toHaveTextContent('Poll created');
    expect(screen.getByText('3 people have answered')).toBeInTheDocument();
  });
});
