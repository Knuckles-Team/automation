import React, { useState, DragEvent } from 'react';
import './DragAndDrop.css';

interface DragAndDropProps {
  // Add any props if needed
}

const DragAndDrop: React.FC<DragAndDropProps> = () => {
  const [selected, setSelected] = useState<HTMLElement | null>(null);

  const handleDragStart = (e: React.DragEvent<HTMLDivElement>): void => {
    setSelected(e.currentTarget);
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>): void => {
    e.preventDefault();
  };

  const handleDrop = (e: DragEvent<HTMLDivElement>, boxId: string): void => {
    const targetBox = document.getElementById(boxId);
    if (targetBox) {
      targetBox.appendChild(selected as Node);
      setSelected(null);
    }
  };

  return (
    <div className="container">
      <div className="card">
        <h2>Welcome to Genius Chat</h2>
            <p>Genius chat is an Artificial General Intelligence (AGI) platform.
              Select one or more from the various agents to build the dreamteam to solve your problem or answer your question.
              If you do not see an agent to meet your needs, feel free to go to the left hand menu and create a new agent!
              Once you have your agents ready, send your prompt.</p>
        <br></br>
        <hr></hr>
        <br></br>
        <h3>Select Agent(s) to Chat</h3>
        <div
          className="cardList"
          >
          <div
            id="left"
            onDragOver={(e) => handleDragOver(e)}
            onDrop={(e) => handleDrop(e, 'left')}
          >
            <div
              className="list"
              draggable
              onDragStart={(e) => handleDragStart(e)}
            >
              <img src={process.env.PUBLIC_URL+'/assets/DragDropIcon.png'} alt="Financial Advisor" />
              <span>Engineer</span>
            </div>
            <div
              className="list"
              draggable
              onDragStart={(e) => handleDragStart(e)}
            >
              <img src={process.env.PUBLIC_URL+'/assets/DragDropIcon.png'} alt="Financial Advisor" />
              <span>Financial Advisor</span>
            </div>
          </div>
    
          <div
            id="right"
            onDragOver={(e) => handleDragOver(e)}
            onDrop={(e) => handleDrop(e, 'right')}
          >
            <div
              className="list"
              draggable
              onDragStart={(e) => handleDragStart(e)}
              >
              <img src={process.env.PUBLIC_URL+'/assets/DragDropIcon.png'} alt="Assistant" />
              <span>Assistant</span>
            </div>
            {/* Items in the right box */}
          </div>
        </div>        
      </div>
    </div>
  );
};

export default DragAndDrop;