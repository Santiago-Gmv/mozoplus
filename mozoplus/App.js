import React from 'react';
import { LanguageProvider } from './src/context/LanguageContext';
import LoginScreen from './src/screens/LoginScreen';

export default function App() {
  return (
    <LanguageProvider>
      <LoginScreen />
    </LanguageProvider>
  );
} 