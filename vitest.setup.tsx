import '@testing-library/jest-dom';
import React from 'react';

// Mock Inertia
vi.mock('@inertiajs/react', () => ({
  usePage: vi.fn(() => ({
    props: {
      // Default mock props here
    },
  })),
  Link: vi.fn(({ children, ...props }) => {
    return <a {...props}>{children}</a>;
  }),
  Head: vi.fn(({ children, ...props }) => {
    return <title {...props}>{children}</title>;
  }),
  router: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    patch: vi.fn(),
    delete: vi.fn(),
    reload: vi.fn(),
    visit: vi.fn(),
  },
}));