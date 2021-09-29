//
//  Array2D.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/29.
//

import Foundation

public struct Array2D<T> {
    public let columns: Int
    public let rows: Int
    fileprivate var array: [T]
    
    public init(columns: Int, rows: Int, initialValue: T) {
        self.columns = columns
        self.rows = rows
        array = .init(repeating: initialValue, count: rows*columns)
    }
    
    public subscript(column: Int, row: Int) -> T {
        get {
            precondition(
                column < columns,
                "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))"
            )
            
            precondition(
                row < rows,
                "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))"
            )
            
            return array[row*columns + column]
        }
        set {
            
            precondition(
                column < columns,
                "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))"
            )
            
            precondition(
                row < rows,
                "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))"
            )
            
            array[row*columns + column] = newValue
        }
    }
}
