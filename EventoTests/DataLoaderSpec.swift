//
//  DataLoaderSpec.swift
//  EventoTests
//
//  Created by Aleksey Bykhun on 12.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//
// Swift

import Quick
import Nimble
import FacebookCore
import BrightFutures
import SwiftyJSON
@testable import Evento

class DataLoaderSpec: QuickSpec {
    override func spec() {
        it("is") {
            expect(true).to(beTruthy())
        }
    }
}


class ListEventsViewControllerSpec: QuickSpec {
    static let mockJSON1 = "{ \"description\": \"Jesus loves you\", \"owner\": { \"name\": \"Underground Moscow\", \"id\": \"811205345657873\" }, \"cover\": { \"offset_x\": 0, \"offset_y\": 55, \"source\": \"https://scontent.xx.fbcdn.net/v/t1.0-9/s720x720/16195990_1053676351410770_5339118705210086921_n.jpg?oh=848285a734dc043497bcf002f3c95989&oe=5AB310DC\", \"id\": \"1053676351410770\" }, \"start_time\": \"2020-01-07T22:00:00+0300\", \"id\": \"794531934033740\" }"
    static let mockJSON2 = "{ \"description\": \"░ ░ ░ ░ RAVE ALERT: ACID NIGHT ░ ░ ░ ░ ☺ MR. GASMASK (Binary Bassline, We Are Rave, LIVE) ☺ SEVENUM SIX (Obs.cure, Kromatones, LIVE) ☺ JACIDOREX (Molekül, NeoAcid, LIVE) ☺ X&TRICK (Bug Klinik, Rave Alert) ☺ ERLENMEYER (Violent Cases, LIVE) ☺ L-REAK vs SOUL3D (Acid Syndrome) ## INFO ## Sat. 17/02/18 @ Black Buddah Warehouse Vaartdijk 98A, 1130 Brussels Doors: 22h30 ++ Tickets ++ # Early Raver: 10 Euro (on sale now) # Regular Raver: 12 Euro # Door: TBA Tickets via http://bit.ly/2B0Dz5f - Rave Alert since 2008 -\", \"owner\": { \"name\": \"Rave Alert\", \"id\": \"515801405123537\" }, \"cover\": { \"offset_x\": 0, \"offset_y\": 50, \"source\": \"https://scontent.xx.fbcdn.net/v/t31.0-8/s720x720/25487182_1581037161933284_1502006924535036478_o.jpg?oh=1eacaa426dd0c9d3e0da6070ca79bb9d&oe=5AFF009A\", \"id\": \"1581037161933284\" }, \"start_time\": \"2018-02-17T22:30:00+0100\", \"id\": \"1136820466453459\" },"
    static let mockJSON3 = "{ \"description\": \"Drab Majesty - Psychic TV, Clan of Xymox, The Frozen Autumn, Prayers, Youth Code, King Dude и Cold Cave. Tickets: https://gosboking.timepad.ru/event/609508/\", \"owner\": { \"name\": \"Grains of Sand Booking\", \"id\": \"151659622100916\" }, \"cover\": { \"offset_x\": 0, \"offset_y\": 38, \"source\": \"https://scontent.xx.fbcdn.net/v/t31.0-0/p480x480/23467206_160260917907453_2588400259483544888_o.jpg?oh=ffb90133ffe6259a6b0d79aa15237431&oe=5AF1078E\", \"id\": \"160260917907453\" }, \"start_time\": \"2018-01-13T20:00:00+0300\", \"id\": \"398166087266998\" },"

    class MockConnection: SocialConnection {
        func loadFriends() -> Future<[User], NSError> {
            let p = Promise<[User], NSError>()
            
            p.success(
                []
            )
            
            return p.future
        }
        
        func loadEvents() -> Future<[Event], NSError> {
            let p = Promise<[Event], NSError>()
            
            p.success([
                Event(json: JSON(mockJSON1)),
                Event(json: JSON(mockJSON2)),
                Event(json: JSON(mockJSON3)),
            ])
            
            return p.future
        }
    }
    
    override func spec() {
        let evc = ListEventsViewController()
        beforeEach {
            evc.tableView = UITableView()
            evc.refreshControl = UIRefreshControl()
            evc._connection = MockConnection()
        }
        it("saves events") {
            evc.loadData()
            
            expect(evc.events.count).toEventually(be(3))
            
        }
        
        it("pins events") {
            let event = evc.setPinned(at: 1)
            
            expect(evc.pinnedEvents.count).to(be(1))
            expect(evc.pinnedEvents.first?.id).to(be(event.id))
        }
        
    }
}

