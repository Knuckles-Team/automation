import React, { useState, DragEvent } from 'react';

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
    <div
      className="cardList"
      >
      <div
        id="left"
        className="list"
        onDragOver={(e) => handleDragOver(e)}
        onDrop={(e) => handleDrop(e, 'left')}
      >
        <div
          draggable
          onDragStart={(e) => handleDragStart(e)}
        >
          Item 1
        </div>
        <div
          draggable
          onDragStart={(e) => handleDragStart(e)}
        >
          Item 2
        </div>
      </div>

      <div
        id="right"
        className="list"
        onDragOver={(e) => handleDragOver(e)}
        onDrop={(e) => handleDrop(e, 'right')}
      >
        {/* Items in the right box */}
      </div>
    </div>
  );
};

export default DragAndDrop;