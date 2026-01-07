"use client";

import React from 'react';
import { Button as PrimeButton } from 'primereact/button';

const $ = typeof window !== 'undefined' ? window.$ : { strings: {} };
export default class Button extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }
  render() {
    return (
      // <button ref={this.props.innerRef} title={this.props.tooltip} className={`${styles.button1} ${this.props.innerClass || ''} `} {...this.props} >
      //     {this.props.children}
      // </button>
      <PrimeButton
        ref={this.props.innerRef}
        label={this.props.label || ' '}
        {...this.props}
        tabIndex={this.props.allowFoucs ? '' : -1}
        style={{ marginInlineStart: '5px', minWidth: '30px', minHeight: '30px', ...this.props.style }}
        tooltipOptions={{ position: 'bottom', style: { direction: 'rtl' } }}
      >
        {this.props.children}
      </PrimeButton>
    );
  }
}
