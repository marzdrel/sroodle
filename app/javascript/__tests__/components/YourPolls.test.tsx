import { screen } from '@testing-library/react';

import YourPolls from '@/components/YourPolls';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

describe('YourPolls', () => {
  test('renders nothing without polls', () => {
    const { container } = renderWithInertia(<YourPolls polls={[]} />);

    expect(container).toBeEmptyDOMElement();
  });

  test('lists polls with their role and a manage link for organizers', () => {
    renderWithInertia(
      <YourPolls
        polls={[
          { id: 'poll_1', name: 'Game night', path: '/poll_1', admin_path: '/poll_1/admin/x', role: 'organizer', closed: false },
          { id: 'poll_2', name: 'Offsite', path: '/poll_2', admin_path: null, role: 'participant', closed: true },
        ]}
      />
    );

    expect(screen.getByRole('link', { name: 'Game night' })).toHaveAttribute('href', '/poll_1');
    expect(screen.getByText('Organizer')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Manage' })).toHaveAttribute('href', '/poll_1/admin/x');
    expect(screen.getByText('Voted')).toBeInTheDocument();
    expect(screen.getByText('Closed')).toBeInTheDocument();
  });
});
