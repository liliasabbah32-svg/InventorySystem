import React, { createRef } from 'react';
import Tooltip from './Tooltip';
import './Label.css';

export default class Label extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      isOverflowing: false,
      tooltipPosition: {}

    };
    this.labelRef = createRef();
    this.cloneRef = createRef();
  }

  componentDidMount() {
    this.checkOverflow();
  }

  componentDidUpdate(prevProps) {
    if (prevProps.text !== this.props.text) {
        this.checkOverflow();
    }
  }

  checkOverflow() {
    const label = this.labelRef.current;
    const clone = this.cloneRef.current;
    const isOverflowing = clone.offsetWidth > label.clientWidth;
    this.setState({ isOverflowing });
  }  

  render() {
    const { isOverflowing } = this.state;
    return (
      <>
      <label data-testid="nameOfLabel" ref={this.labelRef} className={this.props.isFromReport?'labelReport':'label'} {...this.props}>
        {isOverflowing && (
          <Tooltip text={this.props.children} labelStyle={this.props.labelStyle}>
            {this.props.children}
            {this.props.isRequired && (
              <span data-testid="forcedStar" style={{ color: 'red', fontWeight: 'bold' }}>
                &nbsp;*
              </span>
            )}
          </Tooltip>
        )}
        {!isOverflowing && this.props.children}
        {!isOverflowing && this.props.isRequired && (
          <span data-testid="forcedStar" style={{ color: 'red', fontWeight: 'bold' }}>
            &nbsp;*
          </span>
        )}
      </label>
      <div className="clone" ref={this.cloneRef}>
        {this.props.children}
      </div>
      </>
    );
  }
}
