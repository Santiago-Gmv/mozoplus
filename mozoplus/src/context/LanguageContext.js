import React, { createContext, useState, useContext } from 'react';
import es from '../translations/es';
import en from '../translations/en';
import AsyncStorage from '@react-native-async-storage/async-storage';

const LanguageContext = createContext();

export const languages = {
  es: { name: 'Español', translations: es },
  en: { name: 'English', translations: en }
};

export const LanguageProvider = ({ children }) => {
  const [currentLanguage, setCurrentLanguage] = useState('es');

  const changeLanguage = async (langCode) => {
    setCurrentLanguage(langCode);
    await AsyncStorage.setItem('preferredLanguage', langCode);
  };

  const t = (key) => {
    const keys = key.split('.');
    let value = languages[currentLanguage].translations;
    
    for (const k of keys) {
      value = value[k];
    }
    
    return value || key;
  };

  return (
    <LanguageContext.Provider value={{ currentLanguage, changeLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => useContext(LanguageContext); 