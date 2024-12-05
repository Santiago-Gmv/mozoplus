import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Modal, Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useLanguage, languages } from '../context/LanguageContext';

function LoginScreen() {
  const { t, changeLanguage, currentLanguage } = useLanguage();
  const [showLanguagePicker, setShowLanguagePicker] = useState(false);

  return (
    <View style={styles.container}>
      {/* Botón para abrir el selector de idioma */}
      <TouchableOpacity 
        style={styles.languageButton}
        onPress={() => setShowLanguagePicker(true)}
      >
        <Text style={styles.languageButtonText}>
          {languages[currentLanguage].name}
        </Text>
      </TouchableOpacity>

      {/* Modal para el selector de idioma */}
      <Modal
        visible={showLanguagePicker}
        transparent={true}
        animationType="slide"
      >
        <View style={styles.modalContainer}>
          <View style={styles.pickerContainer}>
            <TouchableOpacity 
              style={styles.closeButton}
              onPress={() => setShowLanguagePicker(false)}
            >
              <Text style={styles.closeButtonText}>{t('common.close')}</Text>
            </TouchableOpacity>
            
            <Picker
              selectedValue={currentLanguage}
              onValueChange={(itemValue) => {
                changeLanguage(itemValue);
                setShowLanguagePicker(false);
              }}
              style={styles.picker}
            >
              {Object.entries(languages).map(([code, lang]) => (
                <Picker.Item 
                  key={code} 
                  label={lang.name} 
                  value={code}
                  style={styles.pickerItem}
                />
              ))}
            </Picker>
          </View>
        </View>
      </Modal>

      <View style={styles.loginContainer}>
        <Text style={styles.title}>{t('login.title')}</Text>
        
        <View style={styles.formContainer}>
          <View style={styles.inputContainer}>
            <Text style={styles.label}>{t('login.email')}</Text>
            <TextInput 
              style={styles.input}
              keyboardType="email-address"
              autoCapitalize="none"
              placeholderTextColor="#666"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>{t('login.password')}</Text>
            <TextInput 
              style={styles.input}
              secureTextEntry
              placeholderTextColor="#666"
            />
          </View>

          <TouchableOpacity style={styles.loginButton}>
            <Text style={styles.loginButtonText}>{t('login.submit')}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  languageButton: {
    position: 'absolute',
    top: 40,
    right: 20,
    padding: 10,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    zIndex: 1,
  },
  languageButtonText: {
    fontSize: 16,
    color: '#333',
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  pickerContainer: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingBottom: Platform.OS === 'ios' ? 40 : 0,
  },
  closeButton: {
    padding: 15,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  closeButtonText: {
    fontSize: 16,
    color: '#007AFF',
  },
  picker: {
    width: '100%',
    backgroundColor: '#fff',
  },
  pickerItem: {
    fontSize: 16,
  },
  loginContainer: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  formContainer: {
    width: '100%',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    marginBottom: 8,
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 8,
    fontSize: 16,
    backgroundColor: '#f8f8f8',
    color: '#333',
  },
  loginButton: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default LoginScreen; 