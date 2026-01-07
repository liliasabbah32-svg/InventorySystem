"use client";

import React from 'react';
import styles from './Dropdown.module.scss';
import { Dropdown as PrimeDropdown } from 'primereact/dropdown';
import Label from './Label';
import Util from './Util';
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
  FaBars,
  FaRegCopy,
} from 'react-icons/fa';

const $ = typeof window !== 'undefined' ? window.$ : { strings: {} };
const root = typeof document !== 'undefined' ? document.documentElement : { style: { setProperty: () => {} } };
export default class Dropdown extends React.Component {
  constructor(props) {
    super(props);
    document.documentElement.style.setProperty('--dir', 'rtl');
    this.state = {
      floatLabel: false,
    };
  }

  handleSassVariable = (e) => document.documentElement.style.setProperty('--dir', 'rtl');

  componentDidMount() {
    document.addEventListener('lang', this.handleSassVariable);
  }
  componentWillUnmount() {
    document.removeEventListener('lang', this.handleSassVariable);
  }
  render() {
    let labelStyle = {};
    let _labelStyle = { 
      width: !this.props.ignoreWidth ? 'auto' : (this.props.labelWidth?this.props.labelWidth:''), 
      minWidth: (this.props.minLabelWidth ? this.props.minLabelWidth : '100px') 
    };
    if (this.props.isReportFilter) labelStyle = { display: 'flex', width: '100%' };
    if(this.props.labelStyle) labelStyle = {...labelStyle,...this.props.labelStyle};
    return (
      <div style={labelStyle}>
        {this.props.caption && (
          <Label
            htmlFor={this.props.htmlFor}
            isRequired={this.props.isRequired}
            style={_labelStyle}
          >
            {this.props.caption}
          </Label>
        )}

        {this.props.withgroup && (
          <div className="p-inputgroup">
            <PrimeDropdown
              innerRef={(el) => (this.drpDownObj = el)}
              style={{ flex: '1',overflow: 'hidden' ,Width: '100%' }}
              data-testid={this.props['data-testid']}
              id="float-input"
              // ref={this.props.innerRef}
              ref={(el) => {
                this.drpDownObj = el; // local ref to dropdown instance
                if (this.props.innerRef) {
                  if (typeof this.props.innerRef === 'function') {
                    this.props.innerRef(el); // forward to parent callback ref
                  } else if (this.props.innerRef.current !== undefined) {
                    this.props.innerRef.current = el; // forward to parent object ref
                  }
                }
              }}

              title={this.props.tooltip}
              className={`${styles.dropDown} ${this.props.innerClass || ''} `}
              {...this.props}
              onChange={(e) =>
                {
                  this.props.onChange && this.props.onChange(e);
                  if (this.drpDownObj && this.drpDownObj.focusInput) {
                        setTimeout(() => {
                          this.drpDownObj.focusInput.focus();
                        }, 0);
                      }                
                }
              }
              tooltipOptions={{ position: 'top', style: { direction: 'rtl' } }}
              placeholder={this.props.placeholder }
              optionLabelLang2={this.props.optionLabelLang2 ? this.props.optionLabelLang2 : this.props.optionLabel}
              itemTemplate={this.optionsTemplate}
              valueTemplate={this.selectedOptionTemplate}
              resetFilterOnHide={true}
              options={this.handleOptions()}
              filter={true}
            >
              {this.props.children}
            </PrimeDropdown>
            <span className="p-inputgroup-addon" style={{ verticalAlign: 'bottom' }}>
              <Button data-testid={this.props['data-testid']} onClick={this.props.btn1event} tooltip={this.props.btn1tooltip}            allowFoucs={true}>
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
                {this.props.btn1icon === 'bars' ? <FaBars /> : null}
                {this.props.btn1icon === 'copy' ? <FaRegCopy /> : null}
              </Button>
            </span>
          </div>
        )}

        {!this.props.withgroup && (
          <PrimeDropdown
          // innerRef={(el) => (this.drpDownObj = el)}
            data-testid={this.props['data-testid']}
            style={{ flex: '1',overflow: 'hidden',Width: '100%'  }}
            id="float-input"
            // ref={this.props.innerRef}
            ref={(el) => {
              this.drpDownObj = el; // local ref to dropdown instance
              if (this.props.innerRef) {
                if (typeof this.props.innerRef === 'function') {
                  this.props.innerRef(el); // forward to parent callback ref
                } else if (this.props.innerRef.current !== undefined) {
                  this.props.innerRef.current = el; // forward to parent object ref
                }
              }
            }}
            title={this.props.tooltip}
            className={`${styles.dropDown} ${this.props.innerClass || ''} `}
            {...this.props}
            onChange={(e) =>
              {
                this.props.onChange && this.props.onChange(e);
                if (this.drpDownObj && this.drpDownObj.focusInput) {
                      setTimeout(() => {
                        this.drpDownObj.focusInput.focus();
                      }, 0);
                    }                
              }
            }

            tooltipOptions={{ position: 'top', style: { direction: 'rtl' } }}
            placeholder={this.props.placeholder}
            itemTemplate={this.optionsTemplate}
            valueTemplate={this.selectedOptionTemplate}
            resetFilterOnHide={true}
            options={this.handleOptions()}
          >
            {this.props.children}
          </PrimeDropdown>
        )}
        {this.props.formErrors && this.props.formErrors[this.props.id] && (
          <div data-testid="requiredMessages" className={styles.errorField}>
            {this.props.formErrors[this.props.id]}
          </div>
        )}
      </div>
    );
  }
  onChangeDropDown =()=>
  {
    if(this.props.onChange)this.props.onChange();
    if(this.drpDownObj) this.drpDownObj.focusInput.focus();
  }
  optionsTemplate = (option) => {
    let option_new = this.truncatedLabel(option)
    let statusColor = option.status && option.status !== 1 ? 'red' : '';
    return (
      <div style={{ color: statusColor }} dir={'rtl'}>
        {option_new}
      </div>
    );
  };
  truncatedLabel = (option) => {

    let option_trun = option.code && option.code.length > 0 && option.code+''!=='0' ? option.code + ' / ' : '' 
    option_trun += this.props.optionLabelCode && this.props.optionLabelCode.length > 0 && this.props.optionLabelCode+''!=='0' ? option[this.props.optionLabelCode] + ' / ' : '' 
    option_trun += option[Util.getNameByUserLanguage(this.props.optionLabel, this.props.optionLabelLang2)]
    const truncatedLabel = option_trun;
     //option_trun.length > 70 ? (option_trun.substring(0, 70) + '...').trim() : option_trun;
    return truncatedLabel;
    
  };
  selectedOptionTemplate = (option, props) => {
    if (option) {
      let option_new = this.truncatedLabel(option)
      return (
        <div >
          <div style={{ whiteSpace: "nowrap", overflow: "hidden",minHeight:'16px', textOverflow: "ellipsis", maxWidth: this.props.maxWidth ? this.props.maxWidth : "380px" }}>
            {option_new}
          </div>
        </div>
      );
    } else {
      return <span>{props.placeholder}</span>;
    }
  };

  onFocus = () => {
    this.setState({ floatLabel: true });
  };

  onBlur = () => {
    this.setState({ floatLabel: false });
    //this.props.isRequired && !this.props.value ? this.setState({ showValidationField: true }) : this.setState({ showValidationField: false });
  };

  setFloatLabelStyle = () => {
    if (this.props.value && this.state.floatLabel) return styles.floatLabelWithColorStyle;
    else if (this.props.value) return styles.floatLabelStyle;
    else if (this.state.floatLabel) return styles.floatLabelWithColorStyle;
    else return styles.label;
  };

  handleOptions = () => {
    if (this.props.isReport) {
      return this.props.options;
    } else {
      if (this.props.options)
        return this.props.options.filter(
          (e) => e.status === undefined || e.status + '' === '1' || (this.props.value && e.id + '' === this.props.value.id + '')
        );
      else return [];
    }
  };
}
