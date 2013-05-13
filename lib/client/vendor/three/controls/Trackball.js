/**
 * @author Eberhard Graether / http://egraether.com/
 */

STATE = { NONE: -1, ROTATE: 0, ZOOM: 1, PAN: 2, TOUCH_ROTATE: 3, TOUCH_ZOOM: 4, TOUCH_PAN: 5 };
THREE.TrackballControls = function ( object, domElement ) {

	var _this = this;

	this.object = object;
	this.domElement = ( domElement !== undefined ) ? domElement : document;

	// API

	this.enabled = true;

	this.screen = { width: 0, height: 0, offsetLeft: 0, offsetTop: 0 };
	this.radius = ( this.screen.width + this.screen.height ) / 4;

	this.rotateSpeed = 1.0;
	this.zoomSpeed = 1.2;
	this.panSpeed = 0.3;

	this.noRotate = false;
	this.noZoom = false;
	this.noPan = false;

	this.staticMoving = false;
	this.dynamicDampingFactor = 0.2;

	this.minDistance = 0;
	this.maxDistance = Infinity;

	this.keys = [ 65 /*A*/, 83 /*S*/, 68 /*D*/ ];

	// internals

	this.target = new THREE.Vector3();

	var lastPosition = new THREE.Vector3();
	_this._priv = {};
	_this._priv.state = STATE.NONE;
	_this._priv.prevState = STATE.NONE;

	_this._priv.eye = new THREE.Vector3();

	_this._priv.rotateStart = new THREE.Vector3();
	_this._priv.rotateEnd = new THREE.Vector3();

	_this._priv.zoomStart = new THREE.Vector2();
	_this._priv.zoomEnd = new THREE.Vector2();

	_this._priv.touchZoomDistanceStart = 0;
	_this._priv.touchZoomDistanceEnd = 0;

	_this._priv.panStart = new THREE.Vector2();
	_this._priv.panEnd = new THREE.Vector2();

	// for reset

	this.target0 = this.target.clone();
	this.position0 = this.object.position.clone();
	this.up0 = this.object.up.clone();

	// events

	var changeEvent = { type: 'change' };


	// methods

	this.handleResize = function () {

		this.screen.width = window.innerWidth;
		this.screen.height = window.innerHeight;

		this.screen.offsetLeft = 0;
		this.screen.offsetTop = 0;

		this.radius = ( this.screen.width + this.screen.height ) / 4;

	};

	this.handleEvent = function ( event ) {

		if ( typeof this[ event.type ] == 'function' ) {

			this[ event.type ]( event );

		}

	};

	this.getMouseOnScreen = function ( clientX, clientY ) {

		return new THREE.Vector2(
			( clientX - _this.screen.offsetLeft ) / _this.radius * 0.5,
			( clientY - _this.screen.offsetTop ) / _this.radius * 0.5
		);

	};

	this.getMouseProjectionOnBall = function ( clientX, clientY ) {

		var mouseOnBall = new THREE.Vector3(
			( clientX - _this.screen.width * 0.5 - _this.screen.offsetLeft ) / _this.radius,
			( _this.screen.height * 0.5 + _this.screen.offsetTop - clientY ) / _this.radius,
			0.0
		);

		var length = mouseOnBall.length();

		if ( length > 1.0 ) {

			mouseOnBall.normalize();

		} else {

			mouseOnBall.z = Math.sqrt( 1.0 - length * length );

		}

		_this._priv.eye.copy( _this.object.position ).sub( _this.target );

		var projection = _this.object.up.clone().setLength( mouseOnBall.y );
		projection.add( _this.object.up.clone().cross( _this._priv.eye ).setLength( mouseOnBall.x ) );
		projection.add( _this._priv.eye.setLength( mouseOnBall.z ) );

		return projection;

	};

	this.rotateCamera = function () {

		var angle = Math.acos( _this._priv.rotateStart.dot( _this._priv.rotateEnd ) / _this._priv.rotateStart.length() / _this._priv.rotateEnd.length() );

		if ( angle ) {

			var axis = ( new THREE.Vector3() ).crossVectors( _this._priv.rotateStart, _this._priv.rotateEnd ).normalize(),
				quaternion = new THREE.Quaternion();

			angle *= _this.rotateSpeed;

			quaternion.setFromAxisAngle( axis, -angle );

			_this._priv.eye.applyQuaternion( quaternion );
			_this.object.up.applyQuaternion( quaternion );

			_this._priv.rotateEnd.applyQuaternion( quaternion );

			if ( _this.staticMoving ) {

				_this._priv.rotateStart.copy( _this._priv.rotateEnd );

			} else {

				quaternion.setFromAxisAngle( axis, angle * ( _this.dynamicDampingFactor - 1.0 ) );
				_this._priv.rotateStart.applyQuaternion( quaternion );

			}

		}

	};

	this.zoomCamera = function () {

		if ( _this._priv.state === STATE.TOUCH_ZOOM ) {

			var factor = _this._priv.touchZoomDistanceStart / _this._priv.touchZoomDistanceEnd;
			_this._priv.touchZoomDistanceStart = _this._priv.touchZoomDistanceEnd;
			_this._priv.eye.multiplyScalar( factor );

		} else {

			var factor = 1.0 + ( _this._priv.zoomEnd.y - _this._priv.zoomStart.y ) * _this.zoomSpeed;

			if ( factor !== 1.0 && factor > 0.0 ) {

				_this._priv.eye.multiplyScalar( factor );

				if ( _this.staticMoving ) {

					_this._priv.zoomStart.copy( _this._priv.zoomEnd );

				} else {

					_this._priv.zoomStart.y += ( _this._priv.zoomEnd.y - _this._priv.zoomStart.y ) * this.dynamicDampingFactor;

				}

			}

		}

	};

	this.panCamera = function () {

		var mouseChange = _this._priv.panEnd.clone().sub( _this._priv.panStart );

		if ( mouseChange.lengthSq() ) {

			mouseChange.multiplyScalar( _this._priv.eye.length() * _this.panSpeed );

			var pan = _this._priv.eye.clone().cross( _this.object.up ).setLength( mouseChange.x );
			pan.add( _this.object.up.clone().setLength( mouseChange.y ) );

			_this.object.position.add( pan );
			_this.target.add( pan );

			if ( _this.staticMoving ) {

				_this._priv.panStart = _this._priv.panEnd;

			} else {

				_this._priv.panStart.add( mouseChange.subVectors( _this._priv.panEnd, _this._priv.panStart ).multiplyScalar( _this.dynamicDampingFactor ) );

			}

		}

	};

	this.checkDistances = function () {

		if ( !_this.noZoom || !_this.noPan ) {

			if ( _this.object.position.lengthSq() > _this.maxDistance * _this.maxDistance ) {

				_this.object.position.setLength( _this.maxDistance );

			}

			if ( _this._priv.eye.lengthSq() < _this.minDistance * _this.minDistance ) {

				_this.object.position.addVectors( _this.target, _this._priv.eye.setLength( _this.minDistance ) );

			}

		}

	};

	this.update = function () {

		_this._priv.eye.subVectors( _this.object.position, _this.target );

		if ( !_this.noRotate ) {

			_this.rotateCamera();

		}

		if ( !_this.noZoom ) {

			_this.zoomCamera();

		}

		if ( !_this.noPan ) {

			_this.panCamera();

		}

		_this.object.position.addVectors( _this.target, _this._priv.eye );

		_this.checkDistances();

		_this.object.lookAt( _this.target );

		if ( lastPosition.distanceToSquared( _this.object.position ) > 0 ) {

			_this.dispatchEvent( changeEvent );

			lastPosition.copy( _this.object.position );

		}

	};

	this.reset = function () {

		_this._priv.state = STATE.NONE;
		_this._priv.prevState = STATE.NONE;

		_this.target.copy( _this.target0 );
		_this.object.position.copy( _this.position0 );
		_this.object.up.copy( _this.up0 );

		_this._priv.eye.subVectors( _this.object.position, _this.target );

		_this.object.lookAt( _this.target );

		_this.dispatchEvent( changeEvent );

		lastPosition.copy( _this.object.position );

	};

	// listeners

	function keydown( event ) {

		if ( _this.enabled === false ) return;

		window.removeEventListener( 'keydown', keydown );

		_this._priv.prevState = _this._priv.state;

		if ( _this._priv.state !== STATE.NONE ) {

			return;

		} else if ( event.keyCode === _this.keys[ STATE.ROTATE ] && !_this.noRotate ) {

			_this._priv.state = STATE.ROTATE;

		} else if ( event.keyCode === _this.keys[ STATE.ZOOM ] && !_this.noZoom ) {

			_this._priv.state = STATE.ZOOM;

		} else if ( event.keyCode === _this.keys[ STATE.PAN ] && !_this.noPan ) {

			_this._priv.state = STATE.PAN;

		}

	}

	function keyup( event ) {

		if ( _this.enabled === false ) return;

		_this._priv.state = _this._priv.prevState;

		window.addEventListener( 'keydown', keydown, false );

	}

	function mousedown( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		if ( _this._priv.state === STATE.NONE ) {

			_this._priv.state = event.button;

		}

		if ( _this._priv.state === STATE.ROTATE && !_this.noRotate ) {

			_this._priv.rotateStart = _this._priv.rotateEnd = _this.getMouseProjectionOnBall( event.clientX, event.clientY );

		} else if ( _this._priv.state === STATE.ZOOM && !_this.noZoom ) {

			_this._priv.zoomStart = _this._priv.zoomEnd = _this.getMouseOnScreen( event.clientX, event.clientY );

		} else if ( _this._priv.state === STATE.PAN && !_this.noPan ) {

			_this._priv.panStart = _this._priv.panEnd = _this.getMouseOnScreen( event.clientX, event.clientY );

		}

		document.addEventListener( 'mousemove', mousemove, false );
		document.addEventListener( 'mouseup', mouseup, false );

	}

	function mousemove( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		if ( _this._priv.state === STATE.ROTATE && !_this.noRotate ) {

			_this._priv.rotateEnd = _this.getMouseProjectionOnBall( event.clientX, event.clientY );

		} else if ( _this._priv.state === STATE.ZOOM && !_this.noZoom ) {

			_this._priv.zoomEnd = _this.getMouseOnScreen( event.clientX, event.clientY );

		} else if ( _this._priv.state === STATE.PAN && !_this.noPan ) {

			_this._priv.panEnd = _this.getMouseOnScreen( event.clientX, event.clientY );

		}

	}

	function mouseup( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		_this._priv.state = STATE.NONE;

		document.removeEventListener( 'mousemove', mousemove );
		document.removeEventListener( 'mouseup', mouseup );

	}

	function mousewheel( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		var delta = 0;

		if ( event.wheelDelta ) { // WebKit / Opera / Explorer 9

			delta = event.wheelDelta / 40;

		} else if ( event.detail ) { // Firefox

			delta = - event.detail / 3;

		}

		_this._priv.zoomStart.y += delta * 0.01;

	}

	function touchstart( event ) {

		if ( _this.enabled === false ) return;

		switch ( event.touches.length ) {

			case 1:
				_this._priv.state = STATE.TOUCH_ROTATE;
				_this._priv.rotateStart = _this._priv.rotateEnd = _this.getMouseProjectionOnBall( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			case 2:
				_this._priv.state = STATE.TOUCH_ZOOM;
				var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
				var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;
				_this._priv.touchZoomDistanceEnd = _this._priv.touchZoomDistanceStart = Math.sqrt( dx * dx + dy * dy );
				break;

			case 3:
				_this._priv.state = STATE.TOUCH_PAN;
				_this._priv.panStart = _this._priv.panEnd = _this.getMouseOnScreen( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			default:
				_this._priv.state = STATE.NONE;

		}

	}

	function touchmove( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		switch ( event.touches.length ) {

			case 1:
				_this._priv.rotateEnd = _this.getMouseProjectionOnBall( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			case 2:
				var dx = event.touches[ 0 ].pageX - event.touches[ 1 ].pageX;
				var dy = event.touches[ 0 ].pageY - event.touches[ 1 ].pageY;
				_this._priv.touchZoomDistanceEnd = Math.sqrt( dx * dx + dy * dy )
				break;

			case 3:
				_this._priv.panEnd = _this.getMouseOnScreen( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			default:
				_this._priv.state = STATE.NONE;

		}

	}

	function touchend( event ) {

		if ( _this.enabled === false ) return;

		switch ( event.touches.length ) {

			case 1:
				_this._priv.rotateStart = _this._priv.rotateEnd = _this.getMouseProjectionOnBall( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			case 2:
				_this._priv.touchZoomDistanceStart = _this._priv.touchZoomDistanceEnd = 0;
				break;

			case 3:
				_this._priv.panStart = _this._priv.panEnd = _this.getMouseOnScreen( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

		}

		_this._priv.state = STATE.NONE;

	}

	this.domElement.addEventListener( 'contextmenu', function ( event ) { event.preventDefault(); }, false );

	this.domElement.addEventListener( 'mousedown', mousedown, false );

	this.domElement.addEventListener( 'mousewheel', mousewheel, false );
	this.domElement.addEventListener( 'DOMMouseScroll', mousewheel, false ); // firefox

	this.domElement.addEventListener( 'touchstart', touchstart, false );
	this.domElement.addEventListener( 'touchend', touchend, false );
	this.domElement.addEventListener( 'touchmove', touchmove, false );

	window.addEventListener( 'keydown', keydown, false );
	window.addEventListener( 'keyup', keyup, false );

	this.handleResize();

};
THREE.TrackballControls.STATE = STATE;
THREE.TrackballControls.prototype = Object.create( THREE.EventDispatcher.prototype );
