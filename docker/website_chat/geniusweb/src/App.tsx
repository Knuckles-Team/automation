import React from 'react';
import { useState } from "react";
import { Routes, Route } from "react-router-dom";
import logo from './logo.svg';
import './App.css';
import DragAndDrop from './components/DragAndDrop'; // Adjust the path accordingly
import SideMenu from './components/SideMenu';


function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <h1>Hello World!</h1>
      </header>
      <SideMenu />
      <DragAndDrop /> {/* Use the DragAndDrop component here */}
      <p>
        Edit <code>src/App.tsx</code> and save to reload.
      </p>
      <a
        className="App-link"
        href="https://reactjs.org"
        target="_blank"
        rel="noopener noreferrer"
        >
        Learn React
      </a>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/team" element={<Team />} />
        <Route path="/contacts" element={<Contacts />} />
        <Route path="/invoices" element={<Invoices />} />
        <Route path="/form" element={<Form />} />
        <Route path="/bar" element={<Bar />} />
        <Route path="/pie" element={<Pie />} />
        <Route path="/line" element={<Line />} />
        <Route path="/faq" element={<FAQ />} />
        <Route path="/calendar" element={<Calendar />} />
        <Route path="/geography" element={<Geography />} />
        <Route path="/transactions/" element={<FAQ />} />
      </Routes>
    </div>
    );
}

export default App;