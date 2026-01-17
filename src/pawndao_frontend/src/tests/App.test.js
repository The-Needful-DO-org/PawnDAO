import { test, expect } from 'vitest';
import { render, screen, waitFor } from "@testing-library/svelte";
import '@testing-library/jest-dom/vitest';
import userEvent from '@testing-library/user-event';
import App from '../routes/+page.svelte';
// ./setup/idbSetup.ts
// import indexedDB from 'fake-indexeddb';
// import { IDBRequest } from 'fake-indexeddb';
// globalThis.indexedDB = indexedDB;
// globalThis.IDBRequest = IDBRequest;

test('mount component', async () => {
  render(App, { props: {} });

  const greetingText = screen.getByText("The People's Pawn Shop");
  expect(greetingText).toHaveTextContent("The People's Pawn Shop");

});


// these tests are svelte only
// cant use backend here must use e2e for frontend + backend
//test('fills and submits a form', async () => {
//  const user = userEvent.setup();
//  // render(App, { props: {} });
//
//  const input = screen.getByRole('textbox', { name: "Enter your name:" });
//  // const input = screen.getByRole('textbox');
//  await user.type(input, 'John Doe');
//  // expect(input).toHaveValue('John Doe');
//  expect(input.value).toBe('John Doe');
//  const button = screen.getByRole('button', { name: "Click Me!" });
//  // with bind frontend only
//  // await waitFor(() => screen.getByText(/John Doe/i));
//  // const greetingText = screen.getByText('John Doe');
//  // expect(greetingText).toHaveTextContent('John Doe');
//
//  // with backend
//  // await user.click(button);
//  // await waitFor(() => screen.getByText(/Hello, John Doe!/i));
//  // const greetingText = screen.getByText('Hello, John Doe!');
//  // expect(greetingText).toHaveTextContent('Hello, John Doe!');
//});
