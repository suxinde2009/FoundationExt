//
//  TestHelpers.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/12.
//

import Foundation

func delay(_ time: Double, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) { block() }
}
