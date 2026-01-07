import React from 'react';


export interface Column {
  name: string;
  field?: string;
  headerAlign?: string;
  filterable?: boolean;
  filterValue?: any;
  type?: string | 'string' | 'number';
  footerOperations?: {
    sum?: boolean;
    min?: boolean;
    max?: boolean;
    avg?: boolean;
    count?: boolean;
  };
  groupBy?: boolean;
}

export interface Scheme {
  name?: string;
  filter?: boolean;
  sigma?: boolean;
  group?: boolean;
  groupField?: string;
  groupSortOrder?: string;
  sortField?: string;
  sortOrder?: string;
  columns: Column[];
  showFooter?: boolean;
}

/** Create a deep copy of the default scheme with headers aligned center */
export function create(defaultScheme: Scheme): Scheme {
  let obj = { ...defaultScheme };
  obj.columns = defaultScheme.columns.map((c) => ({ ...c, headerAlign: 'center' }));
  return obj;
}

/** Create default filters for the scheme */
export function createFilters(defaultScheme: Scheme) {
  return defaultScheme.columns.map((c) =>
    !c.filterable || c.filterable === true
      ? {
          name: c.name,
          type: c.type ? c.type : 'string',
          operator: c.type === 'number' ? 'gte' : 'contains',
          value: c.filterValue ? c.filterValue : '',
        }
      : { name: '', type: 'string', operator: 'contains', value: '' }
  );
}

/** Create summary reducer for footer calculations */
export function createSummaryReducer(defaultScheme: Scheme) {
  if (!defaultScheme.showFooter) return undefined;
  const filteredCols = defaultScheme.columns.filter((col) => col.footerOperations);

  const initialValue: any = {};
  filteredCols.forEach((col) => {
    initialValue['total' + col.name] = 0;
    initialValue['min' + col.name] = Infinity;
    initialValue['max' + col.name] = 0;
    initialValue['avg' + col.name] = 0;
    initialValue['count' + col.name] = 0;
  });

  return {
    initialValue,
    reducer: (accumulator: any, row: any) => {
      filteredCols.forEach((col) => {
        if (col.footerOperations?.sum) accumulator['total' + col.name] += row[col.name];
        if (col.footerOperations?.min) accumulator['min' + col.name] = Math.min(accumulator['min' + col.name], row[col.name]);
        if (col.footerOperations?.max) accumulator['max' + col.name] = Math.max(accumulator['max' + col.name], row[col.name]);
        if (col.footerOperations?.avg) accumulator['avg' + col.name] += row[col.name];
      });
      return accumulator;
    },
    complete: (accumulator: any, arr: any[]) => {
      filteredCols.forEach((col) => {
        if (col.footerOperations?.avg) accumulator['avg' + col.name] = (accumulator['avg' + col.name] / arr.length).toFixed(2);
        if (col.footerOperations?.count) accumulator['count' + col.name] = arr.length;
      });
      return accumulator;
    },
  };
}

/** Create footer rows with JSX renderers */
export function createFooterRows(defaultScheme: Scheme) {
  if (!defaultScheme.showFooter) return undefined;
  const filteredCols = defaultScheme.columns.filter((col) => col.footerOperations);

  return [
    {
      render: filteredCols.reduce((acc: any, col) => {
        acc[col.name] = ({ summary }: any) => (
          <div>
            {col.footerOperations?.sum && (
              <div>
                {'$.strings.sigmaOptions.sum'}: {summary['total' + col.name]}
              </div>
            )}
            {col.footerOperations?.min && (
              <div>
                {'$.strings.sigmaOptions.minimum'}: {summary['min' + col.name]}
              </div>
            )}
            {col.footerOperations?.max && (
              <div>
                {'$.strings.sigmaOptions.maximum'}: {summary['max' + col.name]}
              </div>
            )}
            {col.footerOperations?.avg && (
              <div>
                {'$.strings.sigmaOptions.average'}: {summary['avg' + col.name]}
              </div>
            )}
            {col.footerOperations?.count && (
              <div>
                {'$.strings.sigmaOptions.count'}: {summary['count' + col.name]}
              </div>
            )}
          </div>
        );
        return acc;
      }, {}),
    },
  ];
}

/** Return group column names if grouping is allowed */
export function createGroupColumn(defaultScheme: Scheme, allowGrouping: boolean) {
  if (!allowGrouping) return undefined;
  return defaultScheme.columns.filter((col) => col.groupBy).map((c) => c.name);
}
