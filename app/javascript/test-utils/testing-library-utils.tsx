import { usePage } from '@inertiajs/react';
import { render, RenderOptions, screen, waitFor, fireEvent, within, act } from '@testing-library/react';
import React, { ReactElement } from 'react';

// Create a custom wrapper for rendering with test props
interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  inertiaProps?: Record<string, any>;
}

// Mock usePage to return our test props
const mockUsePage = usePage as unknown as jest.Mock;

export function renderWithInertia(
  ui: ReactElement,
  { inertiaProps = {}, ...renderOptions }: CustomRenderOptions = {}
) {
  // Set up the mock props for this test
  mockUsePage.mockImplementation(() => ({
    props: inertiaProps,
  }));

  return render(ui, { ...renderOptions });
}

// Export testing library utilities
export { screen, waitFor, fireEvent, within, act };
