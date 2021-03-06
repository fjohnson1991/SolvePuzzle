//
//  PuzzleViewModel.swift
//  SolvePuzzle
//
//  Created by Felicity Johnson on 2/19/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import Foundation
import UIKit

class PuzzleViewModel {
    
    var imageSlices: [UIImage]!
    var originalImageOrderArray: [UIImage]!
    var programmerArray: [Programmer]!
    var isSolved = false
    
    init(imageSlices: [UIImage], originalImageOrderArray: [UIImage], programmerArray: [Programmer]) {
        self.imageSlices = imageSlices
        self.originalImageOrderArray = originalImageOrderArray
        self.programmerArray = programmerArray
    }
    
    convenience init() {
        self.init(imageSlices: [], originalImageOrderArray: [], programmerArray: [])
    }
    
    // MARK: - Populate & configure data
    private func populateImages() {
        for name in 1...8 {
            if let image = UIImage(named:String(name)){
                imageSlices.append(image)
                originalImageOrderArray.append(image)
            }
        }
    }
    
    private func randomize() {
        for num in 0..<8 {
            let randomIndex = Int(arc4random_uniform(UInt32(imageSlices.count)))
            if num != randomIndex {
                swap(&imageSlices[num], &imageSlices[randomIndex])
            }
        }
    }
    
    private func checkCellCount() {
        if programmerArray.count < imageSlices.count {
            let newProg = Programmer()
            programmerArray.append(newProg)
        }
    }
    
    private func getJson(with completion: @escaping ([[String: Any]]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "ios_model_challenge", ofType: "json") else { print("error unwrapping json playgrounds file path"); return }
        do {
            let data = try? NSData(contentsOfFile: filePath, options: .uncached)
            guard let castedData = data as? Data else { print("Error casting data as Data"); return }
            guard let rawDictionary = try JSONSerialization.jsonObject(with: castedData, options: []) as? [String : Any] else { print("Error serializing JSON"); return }
            guard let response = rawDictionary["response"] as? [String: Any] else { print("Error retrieving rawDictionary[response]"); return }
            guard let parsedJSON = response["locations"] as? [[String: Any]] else { print("Error retrieving response[locations]"); return }
            completion(parsedJSON)
        } catch {}
    }
    
    private func populateProgrammerInfo() {
        getJson { (parsedJson) in
            for location in parsedJson {
                guard let location = Location(dict: location) else { print("Error unwrapping location in populateProgInfo"); return }
                for service in location.services {
                    guard let platform = service["platform"] as? String else { print("Error retrieving platform"); return }
                    guard let programmers = service["programmers"] as? [[String: Any]] else { print("Error getting service[programmers]"); return }
                    for prog in programmers {
                        let newProg = Programmer(dict: prog)
                        guard let unwrappedNewProg = newProg else { print("Error unwrapping programmer in populateProgrammerInfo"); return }
                        unwrappedNewProg.location = location
                        unwrappedNewProg.platform = platform
                        self.programmerArray.append(unwrappedNewProg)
                    }
                }
            }
        }
    }
    
    // MARK: - Puzzle specific funcs
    func tryToSolvePuzzle() {
        imageSlices.removeAll()
        programmerArray.removeAll()
        populateImages()
        randomize()
        populateProgrammerInfo()
        checkCellCount()
        isSolved = false
    }
    
    func skipPuzzle() {
        isSolved = true
        imageSlices.removeAll()
        programmerArray.removeAll()
        populateImages()
        populateProgrammerInfo()
        checkCellCount()
    }
    
    func moveCell(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = imageSlices.remove(at: sourceIndexPath.item)
        imageSlices.insert(itemToMove, at: destinationIndexPath.item)
    }
    
    func playAgain() {
        imageSlices.removeAll()
        originalImageOrderArray.removeAll()
        programmerArray.removeAll()
        isSolved = false
    }
}
