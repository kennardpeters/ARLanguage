//
//  DataHelper.swift
//  AssociateART
//
//  Created by Kennard Peters on 4/29/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import CoreData
import simd

class DataHelper {
    var context: NSManagedObjectContext
    var entityDict: [Association]
    required init(context: NSManagedObjectContext) {
        self.context = context
        self.entityDict = []
    }
    //Core Data helpers VC variables: self.context, Association
    public func fetchMEC() {
        
        // Fetch the data from Core Data in order to display
        do {
            self.entityDict = try self.context.fetch(Association.fetchRequest())
        }
        catch {
            
        }
        
    }
    //Doesn't need to be in view controller? VC variables: self.context
    func addData(name: String, color: String, transform: float4x4) -> UUID{
        //Create a MEC object
        let newEntity = Association(context: self.context)
        //Save the color String into a MEC db object
        newEntity.color = color
        //Save the rendered word String into a MEC db object
        newEntity.word = name
        newEntity.id = UUID()
        newEntity.awakeFromInsert()
        //Save the flattened out transform into a MEC db object
        newEntity.transform = transform.flatOut()
        do {
            try self.context.save()
        }
        catch {
            
        }
        // Re-fetch the data
        self.fetchMEC()
        return newEntity.id!
    }
    //VC Variables: entityDict, self.context, fetchMEC()
    func deleteData(id: UUID) {
        //If the entityDict is empty return since nothing to delete
        guard entityDict != nil else{
            return
        }
        for entity in self.entityDict {
            if (entity.id == id) {
                self.context.delete(entity)
                break
            }
        }
        do {
            try self.context.save()
        }
        catch {
            print("Save failed")
        }
        self.fetchMEC()
    }
}
