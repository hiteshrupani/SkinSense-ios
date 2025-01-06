//
//  HistoryItemView.swift
//  SkinCancerDetection
//
//  Created by Hitesh Rupani on 22/10/24.
//

import SwiftUI

struct HistoryItemView: View {
    
    var item: DetectionHistoryEntity
    
    var body: some View {
        HStack {
            Text(item.result?.capitalized ?? "N/A")
                .font(.headline)
            
            Spacer()
            
            VStack (alignment: .trailing, spacing: 2) {
                Text(item.date?.formatted(date: .omitted, time: .shortened) ?? "N/A")
                
                Text((item.date?.formatted(date: .abbreviated, time: .omitted)) ?? "N/A")
            }
            .font(.subheadline)
                
        }
    }
}
