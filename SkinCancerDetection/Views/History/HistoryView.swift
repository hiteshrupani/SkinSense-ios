//
//  HistoryView.swift
//  SkinCancerDetection
//
//  Created by Hitesh Rupani on 22/10/24.
//

import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text ("History")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color(.label))
                .padding()
                .padding(.top)
            
            if !vm.savedHistory.isEmpty {
                HStack {
                    Text("Result")
                    Spacer()
                    Text("Date")
                        .frame(width: UIScreen.main.bounds.width / 2.6, alignment: .trailing)
                }
                .font(.subheadline)
                .foregroundStyle(Color.gray)
                .padding(.horizontal)
                
                List {
                    ForEach (vm.savedHistory.reversed()) {item in
                        HistoryItemView(item: item)
                    }
                    .onDelete(perform: vm.deleteHistory)
                }
                .listStyle(.plain)
                
            } else {
                Spacer()
                
                VStack {
                    Image(systemName: "exclamationmark.magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        .padding(.bottom)
                    
                    Text("No results found!")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Start scanning to see results!")
                        .font(.subheadline)
                    
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    HistoryView(vm: ViewModel())
}
