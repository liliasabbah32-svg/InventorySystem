import React from 'react';
import styles from './Messages.module.scss';
import { Messages as PrimeMessages } from 'primereact/messages';
import { Toast as PrimeToast } from 'primereact/toast';

//import { Growl as PrimeGrowl } from 'primereact/growl';

export default class Messages extends React.Component {
  render() {
    return (
      <PrimeMessages id="messages-feldArea" ref={this.props.innerRef} className={styles.messageBar} {...this.props} transitionOptions={null} />
      //<PrimeGrowl ref={this.props.innerRef} className={styles.messageBar} {...this.props} position="top-left"/>
    );
  }
}
