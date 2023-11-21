import React, { useState } from 'react';
import './SideMenu.css';

const SideMenu = () => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div>
      <div className={`side-menu ${isOpen ? 'close' : ''}`}>        
        <ul>
          <hr></hr>    
          <li>Chat</li>
          <hr></hr>
          <li>Agents</li>
          <hr></hr>  
          <li>Dashboard</li>
          <hr></hr>    
          {/* Add more menu items as needed */}
        </ul>
      </div>
      <div>
        <button className="toggle-button" onClick={toggleMenu}>
            {isOpen ? 'Menu ⤇' : 'Menu ⤆'}
        </button>
      </div>  
    
    </div>  
  );
};

export default SideMenu;