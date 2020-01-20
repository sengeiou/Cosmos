//
//  SortedSet.swift
//  Cosmos
//
//  Created by Samuel Yanez on 9/7/19.
//  Copyright © 2019 Samuel Yanez. All rights reserved.
//

public struct SortedSet<E>: Collection where E: Hashable, E: Comparable {
    public typealias Element = E
    public typealias Index = Int
    public typealias Indices = CountableRange<Int>

    private var array: [Element] {
        didSet {
            array.sort(by: >)
        }
    }
    
    private var set: Set<Element>

    public init() {
        self.array = []
        self.set = Set()
    }
    
    public init(withCollection collection: [Element]) {
        self.array = []
        self.set = Set()
        self.append(collection)
    }
    
    public var count: Int {
        array.count
    }

    public var isEmpty: Bool {
        array.isEmpty
    }

    public var contents: [Element] {
        array
    }
    
    public func element(at index: Int) -> Element {
        array[index]
    }

    public func contains(_ element: Element) -> Bool {
        set.contains(element)
    }

    public mutating func append(_ element: Element) {
        if set.insert(element).inserted {
            array.append(element)
        }
    }
    
    public mutating func append(_ collection: [Element]) {
        for element in collection {
            append(element)
        }
    }
    
    public mutating func remove(_ element: Element) {
        if let element = set.remove(element) {
            array.removeAll { $0 == element }
        }
    }
}

extension SortedSet: Equatable {
    static public func == <T>(lhs: SortedSet<T>, rhs: SortedSet<T>) -> Bool {
        return lhs.contents == rhs.contents
    }
}

extension SortedSet: RandomAccessCollection {
    public var startIndex: Int {
        contents.startIndex
    }
    
    public var endIndex: Int {
        contents.endIndex
    }
    
    public subscript(index: Int) -> Element {
        contents[index]
    }
}
