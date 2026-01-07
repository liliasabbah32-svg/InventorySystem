"use client";

import React from 'react';

const $ = typeof window !== 'undefined' ? window.$ : { strings: {} };
// export function toJson(schemeObject) {
//     let obj = {}
//     obj.name = schemeObject.name
//     obj.filter = schemeObject.filter
//     obj.sigma = schemeObject.sigma
//     obj.group = schemeObject.group
//     obj.groupField = schemeObject.groupField
//     obj.groupSortOrder = schemeObject.groupSortOrder
//     obj.sortField = schemeObject.sortField
//     obj.sortOrder = schemeObject.sortOrder
//     obj.columns = schemeObject.columns.map(c => ({
//         field: c.field,
//         filter: c.filter,
//         filterMatchMode: c.filterMatchMode,
//         position: c.position,
//         width: c.width,
//         hidden: c.hidden,
//         hiddenInColumnChooser: c.hiddenInColumnChooser,
//         sigma: c.sigma,
//     }));

//     return JSON.stringify(obj)
// }

export function create(defaultScheme) {
  let obj = { ...defaultScheme };
  obj.columns = defaultScheme.columns.map((c) => ({ ...c }));
  obj.columns = obj.columns.map((col) => ({ ...col, headerAlign: 'center' }));
  return obj;
}

export function createFilters(defaultScheme) {
  let obj = { ...defaultScheme };
  obj.defaultFilterValue = defaultScheme.columns.map((c) =>
    !c.filterable || c.filterable === true
      ? {
          name: c.name,
          type: c.type ? c.type : 'string',
          operator: c.type === 'number' ? 'gte' : 'contains',
          value: c.filterValue ? c.filterValue : '',
        }
      : { name: '', type: 'string', operator: 'contains', value: '' }
  );
  return obj.defaultFilterValue;
}

export function createSummaryReducer(defaultScheme) {
  let obj = { ...defaultScheme };
  if (!obj.showFooter) return undefined;
  let filteredCols = defaultScheme.columns.filter((col) => col.footerOperations);

  let objInitValue = {};
  for (let i = 0; i < filteredCols.length; i++) {
    objInitValue['total' + filteredCols[i].name] = 0;
    objInitValue['min' + filteredCols[i].name] = Infinity;
    objInitValue['max' + filteredCols[i].name] = 0;
    objInitValue['avg' + filteredCols[i].name] = 0;
    objInitValue['count' + filteredCols[i].name] = 0;
  }

  obj.summaryReducer = {
    initialValue: objInitValue,
    reducer: (accumulator, col) => {
      for (let i = 0; i < filteredCols.length; i++) {
        if (filteredCols[i].footerOperations.sum) {
          accumulator['total' + filteredCols[i].name] += col[filteredCols[i].name];
        }
        if (filteredCols[i].footerOperations.min) {
          accumulator['min' + filteredCols[i].name] = Math.min(accumulator['min' + filteredCols[i].name], col[filteredCols[i].name]);
        }
        if (filteredCols[i].footerOperations.max) {
          accumulator['max' + filteredCols[i].name] = Math.max(accumulator['max' + filteredCols[i].name], col[filteredCols[i].name]);
        }
        if (filteredCols[i].footerOperations.avg) {
          accumulator['avg' + filteredCols[i].name] += col[filteredCols[i].name];
        }
      }
      return accumulator;
    },
    complete: (accumulator, arr) => {
      for (let i = 0; i < filteredCols.length; i++) {
        if (filteredCols[i].footerOperations.avg) {
          accumulator['avg' + filteredCols[i].name] = (accumulator['avg' + filteredCols[i].name] / arr.length).toFixed(2);
        }
        if (filteredCols[i].footerOperations.count) {
          accumulator['count' + filteredCols[i].name] = arr.length;
        }
      }
      return accumulator;
    },
  };
  return obj.summaryReducer;
}

export function createFooterRows(defaultScheme) {
  let obj = { ...defaultScheme };
  if (!obj.showFooter) return undefined;
  let filteredCols = defaultScheme.columns.filter((col) => col.footerOperations);
  obj.footerRows = [{ render: {} }];
  for (let i = 0; i < filteredCols.length; i++) {
    obj.footerRows[0].render[filteredCols[i].name] = ({ summary }) => {
      return (
        <div>
          {filteredCols[i].footerOperations.sum && (
            <div>
              {$.strings.sigmaOptions.sum}: {summary['total' + filteredCols[i].name]}
            </div>
          )}
          {filteredCols[i].footerOperations.min && (
            <div>
              {$.strings.sigmaOptions.minimum}: {summary['min' + filteredCols[i].name]}
            </div>
          )}
          {filteredCols[i].footerOperations.max && (
            <div>
              {$.strings.sigmaOptions.maximum}: {summary['max' + filteredCols[i].name]}
            </div>
          )}
          {filteredCols[i].footerOperations.avg && (
            <div>
              {$.strings.sigmaOptions.average}: {summary['avg' + filteredCols[i].name]}
            </div>
          )}
          {filteredCols[i].footerOperations.avg && (
            <div>
              {$.strings.sigmaOptions.count}: {summary['count' + filteredCols[i].name]}
            </div>
          )}
        </div>
      );
    };
  }
  return obj.footerRows;
}

export function createGroupColumn(defaultScheme, allowGrouping) {
  let obj = { ...defaultScheme };
  if (!allowGrouping) {
    obj.groupColumn = undefined;
  } else {
    obj.groupColumn = defaultScheme.columns.filter((col) => col.groupBy === true).map((c) => c.name);
  }
  return obj.groupColumn;
}

/**
 *
 * @param defaultScheme scheme that you want to change
 * @param scheme your saved scheme
 *
 */
// export function merge(defaultScheme, scheme) {
//     let columnsRef = defaultScheme.columns
//     defaultScheme = { ...defaultScheme, ...scheme }
//     let schemeColumns = scheme.columns.reduce((a, b) => {
//         a[b.field] = b
//         return a
//     }, {})
//     columnsRef.forEach(c => {
//         let schemeColumn = schemeColumns[c.field]
//         if (schemeColumn) {
//             c.filter = schemeColumn.filter
//             c.filterMatchMode = schemeColumn.filterMatchMode
//             c.position = schemeColumn.position
//             c.width = schemeColumn.width
//             c.hidden = schemeColumn.hidden
//             c.hiddenInColumnChooser = schemeColumn.hiddenInColumnChooser
//             c.sigma = schemeColumn.sigma
//         }
//     })
//     defaultScheme.columns = columnsRef
//     return defaultScheme
// }
