import React from 'react';
import styles from './ProgressSpinner.module.scss';
import { ProgressSpinner as PrimeProgressSpinner } from 'primereact/progressspinner';

interface ProgressSpinnerProps {
  loading: boolean;
}

export default class ProgressSpinner extends React.Component<ProgressSpinnerProps> {
  render() {
    const { loading } = this.props;
    const displayStyle = loading ? styles.progressVisible : styles.progressHide;

    return (
      <div className={`${styles.progressSpinner} ${displayStyle}`}>
        <PrimeProgressSpinner
          id="progressSpinnerCircle"
          className={styles.progressPos}
          style={{ width: '100px', height: '100px' }}
          strokeWidth="2"
        />
      </div>
    );
  }
}
