import '@testing-library/jest-dom/vitest';
import { beforeEach, vi } from 'vitest';

// jsdom implements no media playback, and the radio player autoplays on every render.
HTMLMediaElement.prototype.play = vi.fn().mockResolvedValue(undefined);
HTMLMediaElement.prototype.pause = vi.fn();

// The real layout always renders both tags, and several components read them during render.
beforeEach(() => {
  document.head.innerHTML =
    '<meta name="csrf-token" content="test-csrf-token">' +
    '<meta name="bell-sound" content="/assets/bell.mp3">';
});
