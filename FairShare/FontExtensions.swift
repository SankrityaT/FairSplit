//
//  FontExtensions.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import Foundation
import SwiftUI

extension Font {
    static func nunitoRegular(size: CGFloat) -> Font {
        return Font.custom("Nunito-Regular", size: size)
    }
    
    static func nunitoBold(size: CGFloat) -> Font {
        return Font.custom("Nunito-Bold", size: size)
    }
}
