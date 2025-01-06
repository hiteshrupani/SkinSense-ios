//
//  ProgressBarView.swift
//  SkinCancerDetection
//
//  Created by Hitesh Rupani on 06/01/25.
//

import SwiftUI

struct ProgressBarView: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.secondaryLabel))
                    .opacity(0.8)
                
                HStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.label))
                        .frame(width: geo.size.width * progress, alignment: .leading)
                    
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 20)
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(progress: 0.6651439666748047)
            .previewLayout(.sizeThatFits)
    }
}
