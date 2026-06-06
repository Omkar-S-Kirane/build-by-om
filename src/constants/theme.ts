import { Platform } from 'react-native';

export const colors = {
  primary: '#6366f1',
  primaryLight: '#818cf8',
  secondary: '#8b5cf6',
  accent: '#22d3ee',
  accentDark: '#0891b2',

  background: '#0a0a1a',
  surface: '#111128',
  surfaceLight: '#1a1a3e',
  surfaceHighlight: '#222250',

  text: '#f1f5f9',
  textSecondary: '#94a3b8',
  textMuted: '#64748b',

  border: '#1e1e3a',
  borderLight: '#2d2d52',

  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',

  white: '#ffffff',
  black: '#000000',

  gradient: {
    primary: ['#6366f1', '#8b5cf6'] as const,
    accent: ['#22d3ee', '#6366f1'] as const,
    surface: ['#111128', '#0a0a1a'] as const,
    hero: ['#0a0a1a', '#111128', '#1a1a3e'] as const,
  },
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  '2xl': 48,
  '3xl': 64,
  '4xl': 96,
} as const;

export const borderRadius = {
  sm: 6,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
} as const;

export const fontSize = {
  xs: 12,
  sm: 14,
  md: 16,
  lg: 18,
  xl: 20,
  '2xl': 24,
  '3xl': 30,
  '4xl': 36,
  '5xl': 48,
} as const;

export const fontWeight = {
  normal: '400' as const,
  medium: '500' as const,
  semibold: '600' as const,
  bold: '700' as const,
  extrabold: '800' as const,
};

export const fonts = Platform.select({
  ios: {
    sans: 'System',
    mono: 'Menlo',
  },
  android: {
    sans: 'Roboto',
    mono: 'monospace',
  },
  default: {
    sans: 'system-ui, -apple-system, sans-serif',
    mono: 'ui-monospace, monospace',
  },
});

export const layout = {
  maxContentWidth: 900,
  headerHeight: 60,
  tabBarHeight: Platform.select({ ios: 84, default: 64 }),
  sectionPadding: spacing.xl,
} as const;
