"use client";

import React from 'react';
import styles from './Input.module.scss';
import { InputText as PrimeInput } from 'primereact/inputtext';
import Label from './Label';
import Button from './Button';
import {
  FaSearch,
  FaSearchPlus,
  FaAutoprefixer,
  FaSitemap,
  FaTimesCircle,
  FaCheckDouble,
  FaPrint,
  FaLevelDownAlt,
  FaPlus,
  FaUser,
  FaSync,
  FaEraser,
  FaDollarSign,
  FaMoneyBill
} from 'react-icons/fa';

const $ = typeof window !== 'undefined' ? window.$ : { strings: {} };
export default class Input extends React.Component {
  render() {
    let labelStyle = { flexGrow: 1 };
    if (this.props.isReportFilter) labelStyle = { flexGrow: '1', display: 'flex', width: '100%' };
    return (
      <div style={labelStyle}>
        {this.props.caption && (
          <Label
            htmlFor={this.props.id}
            isRequired={this.props.isRequired}
            autoComplete="off"
            style={{ width: !this.props.ignoreWidth ? 'auto' : '', minWidth: this.props.minLabelWidth ? this.props.minLabelWidth : '100px' }}
          >
            {this.props.caption}
          </Label>
        )}
        {this.props.withgroup && (
          <div className="p-inputgroup">
            <PrimeInput
              ref={this.props.innerRef}
              {...this.props}
              autoComplete="off"
              onFocus={this.props.onFocus ? this.props.onFocus : this.onFocus}
              tooltipOptions={{ position: 'bottom', style: { direction: 'rtl' } }}
              //onChange={this.onChange}
            >
              {this.props.children}
            </PrimeInput>
            <span className="p-inputgroup-addon" style={{ verticalAlign: 'bottom' }}>
              {this.props.btn1event && (
                <Button
                  data-testid="searchButton"
                  onClick={this.props.btn1event}
                  tooltip={this.props.btn1tooltip}
                  disabled={this.props.disableBtn1event}
                  allowFoucs={true}
                            //  className={styles.transparentButton}
                >
                  {!this.props.btn1icon || this.props.btn1icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn1icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn1icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn1icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn1icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn1icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn1icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn1icon === 'enter' ? <FaLevelDownAlt className={styles.rotateEnterIcon} /> : null}
                  {this.props.btn1icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn1icon === 'user' ? <FaUser /> : null}
                  {this.props.btn1icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn1icon === 'balance' ? <FaDollarSign /> : null}
                         {this.props.btn1icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              )}
            </span>
          </div>
        )}
        {this.props.with2buttons && (
          <div className="p-inputgroup">
            <PrimeInput
              ref={this.props.innerRef}
              autocomplete="off"
              {...this.props}
              onFocus={this.props.onFocus ? this.props.onFocus : this.onFocus}
              tooltipOptions={{ position: 'bottom', style: { direction: 'rtl' } }}
              //onChange={this.onChange}
            >
              {this.props.children}
            </PrimeInput>
            {this.props.btn1event && (
              <span className="p-inputgroup-addon" style={{ verticalAlign: 'bottom' }}>
                <Button
                  data-testid="searchButton"
                  onClick={this.props.btn1event}
                  tooltip={this.props.btn1tooltip}
                  disabled={this.props.disableBtn1event}
                  allowFoucs={true}
                // className={styles.transparentButton}
                >

                  {this.props.btn1icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn1icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn1icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn1icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn1icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn1icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn1icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn1icon === 'enter' ? <FaLevelDownAlt /> : null}
                  {this.props.btn1icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn1icon === 'user' ? <FaUser /> : null}
                  {this.props.btn1icon === 'sync' ? <FaSync /> : null}
                  {this.props.btn1icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn1icon === 'balance' ? <FaDollarSign /> : null}
                         {this.props.btn1icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              </span>
            )}
            {this.props.btn2event && (
              <span data-testid="updateNumberButtonData" className="p-inputgroup-addon" style={{ verticalAlign: 'bottom', marginInlineStart: '4px' }}>
                <Button
                  data-testid="updateNumberButton"
                  onClick={this.props.btn2event}
                  tooltip={this.props.btn2tooltip}
                  disabled={this.props.disableBtn2event}
                  allowFoucs={true}
                       //       className={styles.transparentButton}
                >

                  {this.props.btn2icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn2icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn2icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn2icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn2icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn2icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn2icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn2icon === 'enter' ? <FaLevelDownAlt /> : null}
                  {this.props.btn2icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn2icon === 'user' ? <FaUser /> : null}
                  {this.props.btn2icon === 'sync' ? <FaSync /> : null}
                  {this.props.btn2icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn2icon === 'balance' ? <FaDollarSign /> : null}
                  {this.props.btn2icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              </span>
            )}
          </div>
        )}
        {this.props.with3buttons && (
          <div className="p-inputgroup">
            <PrimeInput
              ref={this.props.innerRef}
              autocomplete="off"
              {...this.props}
              onFocus={this.props.onFocus ? this.props.onFocus : this.onFocus}
              tooltipOptions={{ position: 'bottom', style: { direction: 'rtl'} }}
              //onChange={this.onChange}
            >
              {this.props.children}
            </PrimeInput>
            {this.props.btn1event && (
              <span className="p-inputgroup-addon" style={{ verticalAlign: 'bottom' }}>
                <Button
                  data-testid="searchButton"
                  onClick={this.props.btn1event}
                  tooltip={this.props.btn1tooltip}
                  disabled={this.props.disableBtn1event}
                  allowFoucs={true}
                            //  className={styles.transparentButton}
                >

                  {this.props.btn1icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn1icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn1icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn1icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn1icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn1icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn1icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn1icon === 'enter' ? <FaLevelDownAlt /> : null}
                  {this.props.btn1icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn1icon === 'user' ? <FaUser /> : null}
                  {this.props.btn1icon === 'sync' ? <FaSync /> : null}
                  {this.props.btn1icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn1icon === 'balance' ? <FaDollarSign /> : null}
                         {this.props.btn1icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              </span>
            )}
            {this.props.btn2event && (
              <span data-testid="updateNumberButtonData" className="p-inputgroup-addon" style={{ verticalAlign: 'bottom', marginInlineStart: '4px' }}>
                <Button
                  data-testid="updateNumberButton"
                  onClick={this.props.btn2event}
                  tooltip={this.props.btn2tooltip}
                  disabled={this.props.disableBtn2event}
                  allowFoucs={true}
                             // className={styles.transparentButton}
                >

                  {this.props.btn2icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn2icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn2icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn2icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn2icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn2icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn2icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn2icon === 'enter' ? <FaLevelDownAlt /> : null}
                  {this.props.btn2icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn2icon === 'user' ? <FaUser /> : null}
                  {this.props.btn2icon === 'sync' ? <FaSync /> : null}
                  {this.props.btn2icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn2icon === 'balance' ? <FaDollarSign /> : null}
                         {this.props.btn2icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              </span>
            )}
            {this.props.btn3event && (
              <span data-testid="btnThreeData" className="p-inputgroup-addon" style={{ verticalAlign: 'bottom', marginInlineStart: '5px' }}>
                <Button
                  data-testid="btnThree"
                  onClick={this.props.btn3event}
                  tooltip={this.props.btn3tooltip}
                  label={this.props.btn3label}
                  disabled={this.props.disableBtn3event}
                  allowFoucs={true}
                          //    className={styles.transparentButton}
                >
                  {this.props.btn3icon === 'search' ? <FaSearch /> : null}
                  {this.props.btn3icon === 'searchPlus' ? <FaSearchPlus /> : null}
                  {this.props.btn3icon === 'codePrefix' ? <FaAutoprefixer /> : null}
                  {this.props.btn3icon === 'accountTree' ? <FaSitemap /> : null}
                  {this.props.btn3icon === 'clear' ? <FaTimesCircle /> : null}
                  {this.props.btn3icon === 'check' ? <FaCheckDouble /> : null}
                  {this.props.btn3icon === 'print' ? <FaPrint /> : null}
                  {this.props.btn3icon === 'enter' ? <FaLevelDownAlt /> : null}
                  {this.props.btn3icon === 'plus' ? <FaPlus /> : null}
                  {this.props.btn3icon === 'user' ? <FaUser /> : null}
                  {this.props.btn3icon === 'sync' ? <FaSync /> : null}
                  {this.props.btn3icon === 'eraser' ? <FaEraser /> : null}
                  {this.props.btn3icon === 'balance' ? <FaDollarSign /> : null}
                         {this.props.btn3icon === 'money' ? <FaMoneyBill /> : null}
                </Button>
              </span>
            )}
          </div>
        )}
        {!this.props.withgroup && !this.props.with2buttons && !this.props.with3buttons && (
          <PrimeInput
            ref={this.props.innerRef}
            autocomplete="off"
            {...this.props}
            onFocus={this.props.onFocus ? this.props.onFocus : this.onFocus}
            tooltipOptions={{ position: 'bottom', style: { direction: 'rtl'} }}
            //onChange={this.onChange}
          >
            {this.props.children}
          </PrimeInput>
        )}
        {this.props.formErrors && this.props.formErrors[this.props.id] && (
          //<span id={this.props.id} className="p-invalid p-d-block">{this.props.formErrors[this.props.id]}</span>
          <div data-testid="requiredMessages" className={styles.errorField}>
            {this.props.formErrors[this.props.id]}
          </div>
        )}
      </div>
    );
  }

  onChange = (e) => {
    // if (this.props.type && (this.props.type + "").toLowerCase() === "code") {
    //   let arabic = /[\u0600-\u06FF]/;
    //   if (arabic.test(e.target.value)) {
    //     return;
    //   }
    // }
    // if (this.props.onChange) {
    //   this.props.onChange()
    // }
  };
  onFocus = (event) => {
    event.target.select();
  };
}
