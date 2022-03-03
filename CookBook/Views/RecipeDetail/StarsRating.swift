//
//  StarsRating.swift
//  CookBook
//
//  Created by Michael Abir on 3/2/22.
//

import SwiftUI

protocol StarsRatingViewController: ObservableObject {
    var rating: Double { get }
    func rateRecipe(_ rating: Int, continuation: @escaping (Double) -> ())
}

struct NewStarsRating: View {
    @ObservedObject var viewController: NewRecipeDetailViewModel
    
    @State private var starNames: [String] = [String](repeating: "star", count: 5)
    @State private var starRotations: [Double] = [Double](repeating: 0, count: 5)
    @State private var starIndexAppeared: [Bool] = [Bool](repeating: false, count: 5)
    
    init(viewController: NewRecipeDetailViewModel) {
        self.viewController = viewController
    }
    
    func rateRecipe(_ rating: Int) {
        viewController.rateRecipe(rating) { newRating in
            let halfStar = newRating.truncatingRemainder(dividingBy: 1) > 0.3
            for index in 0..<5 {
                if index < Int(floor(viewController.rating)) {
                    starNames[index] = "star.fill"
                } else if index == Int(floor(viewController.rating)) && halfStar {
                    starNames[index] = "star.leadinghalf.fill"
                } else {
                    starNames[index] = "star"
                }
                
                starRotations[index] = 0
            }
        }
    }
    
    var body: some View {
        let halfStar = viewController.rating.truncatingRemainder(dividingBy: 1) > 0.3
        
        ForEach(0..<5) { index in
            if index < Int(floor(viewController.rating)) {
                Image(systemName: starNames[index])
                    .foregroundColor(Color.yellow)
                    .rotation3DEffect(.degrees(starRotations[index]), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 + Double(index) * 0.2) {
                                withAnimation(.linear(duration: 1.0)) {
                                    starRotations[index] = 180
                                }
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                    withAnimation(.linear(duration: 0.5)) {
                                        starNames[index] = "star.fill"
                                    }
                                }
                            }
                        }
                    }
            } else if index == Int(floor(viewController.rating)) && halfStar {
                Image(systemName: starNames[index])
                    .foregroundColor(Color.yellow)
                    .rotation3DEffect(.degrees(starRotations[index]), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 + Double(index) * 0.2) {
                                withAnimation(.linear(duration: 1.0)) {
                                    starRotations[index] = 360
                                }
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                    withAnimation(.linear(duration: 0.5)) {
                                        starNames[index] = "star.leadinghalf.fill"
                                    }
                                }
                            }
                        }
                    }
                
            } else {
                Image(systemName: "star")
                    .foregroundColor(Color.yellow)
                    .onTapGesture {
                        rateRecipe(index + 1)
                    }
                    .onAppear {
                        if !starIndexAppeared[index] {
                            starIndexAppeared[index] = true
                        }
                    }
            }
        }
    }
}
