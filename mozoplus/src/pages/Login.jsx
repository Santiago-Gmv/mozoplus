import React from 'react';
import { useLanguage, languages } from '../context/LanguageContext';

function Login() {
  const { t, changeLanguage, currentLanguage } = useLanguage();

  return (
    <div className="login-container">
      <div className="language-selector">
        <select 
          value={currentLanguage}
          onChange={(e) => changeLanguage(e.target.value)}
          className="language-select"
        >
          {Object.entries(languages).map(([code, lang]) => (
            <option key={code} value={code}>
              {lang.name}
            </option>
          ))}
        </select>
      </div>

      <h1 className="login-title aok">{t('login.title')}</h1>
      <form className="login-form">
        <div className="form-group">
          <label>{t('login.email')}</label>
          <input type="email" />
        </div>
        <div className="form-group">
          <label>{t('login.password')}</label>
          <input type="password" />
        </div>
        <button type="submit">{t('login.submit')}</button>
      </form>
    </div>
  );
}

export default Login; 