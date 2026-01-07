import React, { useState, useRef, useEffect } from 'react';
import ReactDOM from 'react-dom';
import './Tooltip.css';

const Tooltip = ({ children, text, labelStyle }) => {
    const [visible, setVisible] = useState(false);
    const [coords, setCoords] = useState({ top: 0, left: 0 });
    const wrapperRef = useRef(null);

    const showTooltip = () => {
        const rect = wrapperRef.current.getBoundingClientRect();
        setCoords({
            top: rect.top + window.scrollY,
            left: rect.left + window.scrollX,
        });
        setVisible(true);
    };

    const hideTooltip = () => setVisible(false);

    return (
        <>
            <div 
                className="tooltip-wrapper"
                onMouseEnter={showTooltip}
                onMouseLeave={hideTooltip}
                ref={wrapperRef}
                style={labelStyle}
            >
                {children}
            </div>
            {visible && ReactDOM.createPortal(
                <div 
                    className="tooltip" 
                    style={{ top: coords.top, left: coords.left,textAlign: 'right'}}
                >
                    {text}
                </div>,
                document.body
            )}
        </>
    );
};

export default Tooltip;
