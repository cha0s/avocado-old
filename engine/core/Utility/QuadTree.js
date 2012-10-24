/*
 * QuadTree Implementation in JavaScript
 * @author: silflow <https://github.com/silflow>
 *
 * Usage:
 * To create a new empty Quadtree, do this:
 * var tree = avo.QuadTree.init(args)
 *
 * args = {
 *    // mandatory fields
 *    x : x coordinate
 *    y : y coordinate
 *    w : width
 *    h : height
 *
 *    // optional fields
 *    maxChildren : max children per node
 *    maxDepth : max depth of the tree
 *}
 *
 * API:
 * tree.insert() takes arrays or single items
 * every item must have a .x and .y property. if not, the tree will break.
 *
 * tree.retrieve(item) returns an array containing all objects that are in
 * the same region or overlapping.
 *
 * tree.clear() removes all items from the quadtree.
 */

module.exports = function(args) {

    var node;
    var TOP_LEFT     = 0;
    var TOP_RIGHT    = 1;
    var BOTTOM_LEFT  = 2;
    var BOTTOM_RIGHT = 3;
    var PARENT       = 4;

    // assign default values
    args.maxChildren = args.maxChildren || 2;
    args.maxDepth = args.maxDepth || 4;
    
    /**
     * Node creator. You should never create a node manually. the algorithm takes
     * care of that for you.
     */
    node = function (x, y, w, h, depth, maxChildren, maxDepth) {

        var children = [], // holds all items
            nodes = []; // holds all subnodes

        // returns a fresh node object
        return {

            x : x, // top left point
            y : y, // top right point
            w : w, // width
            h : h, // height
            depth : depth, // depth level of the node

            /**
             * Returns an array of all objects, that are in the same region or
             * in overlapping regions. For each item the callback is called.
             */
            retrieveRecursive : function (item, callback) {
                for (var i = 0; i < children.length; ++i) {
                    callback(children[i]);
                }
                // check if node has subnodes
                if (nodes.length) {
                    // call retrieve on all matching subnodes
                    this.findOverlappingNodes(item, function(dir) {
                        nodes[dir].retrieveRecursive(item, callback);
                    });
                }
            },

            /**
             * Returns an array containing all objects that are in the same
             * region or overlapping.
             */
            retrieve : function (item) {
            	var objects = [];
            	
            	this.retrieveRecursive(item, function(object) {
            		objects.push(object);
            	});
            	
            	return objects;
            },

            /**
             * Adds a new Item to the node.
             *
             * If the node already has subnodes, the item gets pushed down one level.
             * If the item does not fit into the subnodes, it gets saved in the
             * "children"-array.
             *
             * If the maxChildren limit is exceeded after inserting the item,
             * the node gets divided and all items inside the "children"-array get
             * pushed down to the new subnodes.
             */
            insert : function (item) {

                var i;

                if (nodes.length) {
                    // get the node in which the item fits best
                    i = this.findInsertNode(item)
                    if (i === PARENT) {
                        // if the item does not fit, push it into the
                        // children array
                        children.push(item);
                    } else {
                        nodes[i].insert(item);
                    }
                } else {
                    children.push(item);
                    //divide the node if maxChildren is exceeded and maxDepth is not reached
                    if (children.length > maxChildren && this.depth < maxDepth) {
                        this.divide();
                    }
                }
            },
            
            remove : function(item) {
            	
            	var index;
            	
            	if (-1 !== (index = children.indexOf(item))) {
                	children.splice(index, 1);
            		return true;
            	}
                // check if node has subnodes
                if (nodes.length) {
                    
                	//var self = this;
                	var foundInSubnode = false;
                	
                    this.findOverlappingNodes(item, function(dir) {
                        if (nodes[dir].remove(item)) {
                        	foundInSubnode = dir;
                        }
                    });
                	
                    if (false !== foundInSubnode) {
	                    
	                	var allChildren, i, immediateChildrenCount;
	                	
	                	immediateChildrenCount = children.length;
	            		for (i = 0; i < nodes.length; i++) {
	            			immediateChildrenCount += nodes[i].getChildren().length;
	            		}
	                	
	                	if (immediateChildrenCount <= maxChildren) {
	                		avo.Logger.info(immediateChildrenCount);
	                		return false;
	                	}
	                	
	                	allChildren = this.getAllChildren();
	                	
	                	children.length = 0;
	                	nodes.length = 0;
	                	
	            		for (i = 0; i < allChildren.length; i++) {
	                		this.insert(allChildren[i]);
	            		}
	                	
	            		return nodes.length === 0;
                    }
                }
            },
            
            /**
             * Find a node the item should be inserted in.
             */
            findInsertNode : function (item) {
                // left
                if (item.x + item.w < x + (w / 2)) {
                    if (item.y + item.h < y + (h / 2)) return TOP_LEFT;
                    if (item.y >= y + (h / 2)) return BOTTOM_LEFT;
                    return PARENT;
                }

                // right
                if (item.x >= x + (w / 2)) {
                    if (item.y + item.h < y + (h / 2)) return TOP_RIGHT;
                    if (item.y >= y + (h / 2)) return BOTTOM_RIGHT;
                    return PARENT;
                }

                return PARENT;
            },

            /**
             * Finds the regions the item overlaps with. See constants defined
             * above. The callback is called for every region the item overlaps.
             */
            findOverlappingNodes : function (item, callback) {
                // left
                if (item.x < x + (w / 2)) {
                    if (item.y < y + (h / 2)) callback(TOP_LEFT);
                    if (item.y + item.h >= y + h/2) callback(BOTTOM_LEFT);
                }
                // right
                if (item.x + item.w >= x + (w / 2)) {
                    if (item.y < y + (h / 2)) callback(TOP_RIGHT);
                    if (item.y + item.h >= y + h/2) callback(BOTTOM_RIGHT);
                }
            },

            /**
             * Divides the current node into four subnodes and adds them
             * to the nodes array of the current node. Then reinserts all
             * children.
             */
            divide : function () {

                var width, height, i, oldChildren;
                var childrenDepth = this.depth + 1;
                
                // set dimensions of the new nodes
                width = (w / 2);
                height = (h / 2);
                // create top left node
                nodes.push(node(this.x, this.y, width, height, childrenDepth, maxChildren, maxDepth));
                // create top right node
                nodes.push(node(this.x + width, this.y, width, height, childrenDepth, maxChildren, maxDepth));
                // create bottom left node
                nodes.push(node(this.x, this.y + height, width, height, childrenDepth, maxChildren, maxDepth));
                // create bottom right node
                nodes.push(node(this.x + width, this.y + height, width, height, childrenDepth, maxChildren, maxDepth));

                oldChildren = children;
                children = [];
                for (i = 0; i < oldChildren.length; i++) {
                    this.insert(oldChildren[i]);
                }
            },

            /**
             * Clears the node and all its subnodes.
             */
            clear : function () {
                for (var i = 0; i < nodes.length; i++) nodes[i].clear();
                children.length = 0;
                nodes.length = 0;
            },

            /*
             * convenience method: is not used in the core algorithm.
             * ---------------------------------------------------------
             * returns this nodes subnodes. this is usful if we want to do stuff
             * with the nodes, i.e. accessing the bounds of the nodes to draw them
             * on a canvas for debugging etc...
             */
            getChildren: function () {
                return children;
            },

            /*
             * convenience method: is not used in the core algorithm.
             * ---------------------------------------------------------
             * returns this nodes subnodes. this is usful if we want to do stuff
             * with the nodes, i.e. accessing the bounds of the nodes to draw them
             * on a canvas for debugging etc...
             */
            getNodes : function () {
                return nodes;
            },

            /*
             * convenience method: is not used in the core algorithm.
             * ---------------------------------------------------------
             * returns this nodes subnodes. this is usful if we want to do stuff
             * with the nodes, i.e. accessing the bounds of the nodes to draw them
             * on a canvas for debugging etc...
             */
            getAllChildren: function () {
            	var allChildren, i;
            	
            	allChildren = [];
            	allChildren.push.apply(allChildren, children);
            	for (i = 0; i < nodes.length; i++) {
            		allChildren.push.apply(allChildren, nodes[i].getAllChildren());
            	}
            	
                return allChildren;
            }
        };
    };

    return {

        root : (function () {
            return node(args.x, args.y, args.w, args.h, 0, args.maxChildren, args.maxDepth);
        }()),

        getAllChildren : function (item) {
            return this.root.getAllChildren();
        },

        insert : function (item) {

            var len, i;

            if (item instanceof Array) {
                len = item.length;

                for (i = 0; i < len; i++) {
                    this.root.insert(item[i]);
                }

            } else {
                this.root.insert(item);
            }
        },

        remove : function (item) {
            return this.root.remove(item);
        },

        retrieve : function (item) {
            return this.root.retrieve(item);
        },

        clear : function () {
            this.root.clear();
        }
    };
};