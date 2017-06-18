local w, _ = love.graphics.getDimensions()
local lume = require 'lib.lume'
local Signal = require 'lib.signal'
local collisions = require 'core.collisions'
local Pickup = require 'entity.Pickup'
local Asteroid = require 'entity.Asteroid'

local function splitAsteroid(self, asteroid, damager)
    local left, right, ps = asteroid:split(damager)
    self:group('asteroids'):add(left)
    self:group('asteroids'):add(right)
    self:group('particleSystems'):add(ps)
end

return function() return {
    -- define scene class properties
    properties = {
        score = {
            value = 0,
            get = function(self, value) return value end,
            set = function(self, new) return new end,
            afterSet = function(self, value)
                Signal.emit('changed_score', self, value) end,
        },
    },
    -- define (and initialize if necessary) groups of objects
    groups = {
        shots = {},
        asteroids = {init = function(self)
            for _ = 1, 30 do
                self:group('asteroids'):add(Asteroid.newRandomAtBorders())
            end
        end},
        particleSystems = {},
        pickups = {},
        widgets = {
            scoreLabel = {
                script = 'core.widgets.Label',
                arguments = {x=50, y=50, text='0', prefix='Score\n'}
            },
            timeCounter = {
                script = 'core.widgets.TimeCounter',
                arguments = {x = w-100, y = 50}
            },
        }
    },
    -- define objects that do not belong to a specified group
    objects = {
        spaceShip = {
            script = 'entity.SpaceShip',
            arguments = function(self) return {scene = self, health = 5} end,
        },
        {
            script = 'core.KeyTrigger',
            arguments = function(self) return {key = 'space', action = function()
                Signal.emit('fire_laser', self)
            end} end
        }
    },
    -- registration of signal functions
    signals = {
        fire_laser = {
            function(self)
                love.audio.play('assets/audio/shot' .. lume.randomchoice{1, 2, 3} .. '.wav', 'static', false, .7)
                self.objects.spaceShip:shoot()
            end,
        },
        collision_asteroid_shot = {
            function(self, asteroid, shot)
                splitAsteroid(self, asteroid, shot)
                shot:kill()
                asteroid:kill()
                -- increment score
                self.score = self.score + asteroid.scorePoints
                -- randomly create a pickup
                if love.math.random() < .1 then
                    local p = Pickup(asteroid.x, asteroid.y)
                    p.action = function(spaceShip)
                        spaceShip.shooter = 'triple'
                        self.objects.timer:after(5, function()
                            spaceShip.shooter = 'simple'
                        end)
                    end
                    p.lifetime = 5
                    self:group('pickups'):add(p)
                    self.objects.timer:after(p.lifetime, function()
                        p:kill()
                    end)
                end
                -- play a sound
                love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .7)
            end,
        },
        collision_asteroid_player = {
            function(self, asteroid, player)
                splitAsteroid(self, asteroid, player)
                asteroid:kill()
                self.camera:shake(self.objects.timer, (asteroid.radius/30)^2)
                if player:damage(-1) then
                    love.audio.play('assets/audio/player_dead.wav', 'static', false, .7)
                else
                    love.audio.play('assets/audio/collision.wav', 'static', false, .4)
                end
            end,
        },
        changed_score = {
            function(self, score)
                self:group('widgets').objects.scoreLabel:setText(tostring(score))
            end,
        }
    },
    updateActions = {
        function(self)
            -- check collisions between shots and asteroids
            for _, asteroid in self:each('asteroids') do
                for _, shot in self:each('shots') do
                    if collisions.circleToCircle(shot, asteroid) then
                        Signal.emit('collision_asteroid_shot', self, asteroid, shot)
                    end
                end
            end
        end,
        function(self)
            -- check collisions between asteroids and the player
            for _, asteroid in self:each('asteroids') do
                if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
                    Signal.emit('collision_asteroid_player', self, asteroid, self.objects.spaceShip)
                end
            end
        end,
        function(self)
            -- check collisions between player and pickups
            for _, pickup in self:each('pickups') do
                if collisions.circleToCircle(pickup, self.objects.spaceShip) then
                    pickup:onCollected(self.objects.spaceShip)
                    self:group('pickups'):remove(pickup)
                end
            end
        end,
    }
}
end
