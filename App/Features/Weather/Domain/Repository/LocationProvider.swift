protocol LocationProviding {
    func currentLocation() async throws -> Coordinate
}
