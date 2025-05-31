import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import Index from '@/pages/Poll/Index';
import { renderWithInertia } from '@/test-utils/testing-library-utils';

// Sample mock data
const mockPolls = [
  {
    id: 1,
    name: 'Team Meeting',
    description: 'Weekly team sync-up to discuss progress and blockers',
    creator: {
      email: 'jane.doe@example.com'
    },
    created_at: '2025-05-15T10:00:00Z',
    end_voting_at: '2025-05-20T18:00:00Z',
    path: '/polls/poll_123456',
    vote_path: '/polls/poll_123456/votes'
  },
  {
    id: 2,
    name: 'Product Launch',
    description: 'Planning session for the upcoming product launch',
    creator: {
      email: 'john.smith@example.com'
    },
    created_at: '2025-05-16T14:30:00Z',
    end_voting_at: '2025-05-25T17:00:00Z',
    path: '/polls/poll_789012',
    vote_path: '/polls/poll_789012/votes'
  }
];

describe('Poll Index Component', () => {
  test('renders empty state when no polls are available', () => {
    renderWithInertia(<Index polls={[]} />);

    expect(screen.getByText('No polls available yet')).toBeInTheDocument();
    expect(screen.getByText('Be the first to create a poll for your event!')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /create new poll/i })).toBeInTheDocument();
  });

  test('renders list of polls when available', () => {
    renderWithInertia(<Index polls={mockPolls} />);

    // Check if poll titles are rendered
    expect(screen.getByText('Team Meeting')).toBeInTheDocument();
    expect(screen.getByText('Product Launch')).toBeInTheDocument();

    // Check if creator emails are rendered
    expect(screen.getByText(/jane.doe@example.com/)).toBeInTheDocument();
    expect(screen.getByText(/john.smith@example.com/)).toBeInTheDocument();

    // Check if View Poll buttons are present
    const viewButtons = screen.getAllByRole('button', { name: /view poll/i });
    expect(viewButtons).toHaveLength(2);
  });

  test('has a working create new poll button', async () => {
    const user = userEvent.setup();
    renderWithInertia(<Index polls={mockPolls} />);

    const createButton = screen.getByRole('button', { name: /create new poll/i });
    expect(createButton).toBeInTheDocument();

    await user.click(createButton);

    // In an actual test, you'd verify navigation or some state change
    // Since Link is mocked, we'll just check that the link has the correct href
    expect(createButton.closest('a')).toHaveAttribute('href', '/polls/new');
  });
});
