# AsCompositeHitBox
Flashpunk oriented collision library
The goal this library is to be able to provide a better (or more flexible) collision system to Flashpunk. 
We maintain Flashpunk as vanilla as posible and don't

As is Flashpunk only provide a simple hitbox or a pixel mask to check for collisions, we want to provide a way to create hierachical bounding areas.

Our rationale is that collision could be handled as hierachical bounding areas (implemented as a tree) where leaves of the tree fire a collision, and top and intermediary levels are only intended for quickly filtering bounding areas that don't collide.

Currently we try to handle entity-entity and entity-type collisions, as the current version of Flashpunk does. But we also the collisions with the bounding areas introduced by this library in the same entry point.

## Roadmap
1. Point Inclusion (as is, we don't handle virtual coords for isPointInside check, also add tests for this).
2. Collision queries.
3. Spatial partitioning.
4. TBD.

## TODO
1. Improve readme section.
