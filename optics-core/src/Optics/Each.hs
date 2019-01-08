{-# LANGUAGE UndecidableInstances #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Optics.Each
-- Copyright   :  (C) 2012-16 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable
--
-----------------------------------------------------------------------------
module Optics.Each
  (
  -- * Each
    Each(..)
  ) where

import Data.Array.IArray as IArray
import Data.Array.Unboxed as Unboxed
import Data.Complex
import Data.Functor.Identity
import Data.IntMap as IntMap
import Data.List.NonEmpty
import Data.Map as Map
import Data.Sequence as Seq
import Data.Tree as Tree

import Optics.Traversal

-- | Extract 'each' element of a (potentially monomorphic) container.
--
-- >>> (1,2,3) & each %~ (*10)
-- (10,20,30)
--
class Each s t a b | s -> a, t -> b, s b -> t, t a -> s where
  each :: Traversal i s t a b
  default each :: (Traversable g, s ~ g a, t ~ g b) => Traversal i s t a b
  each = traversed
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a) (b,b) a b@
instance (a~a', b~b') => Each (a,a') (b,b') a b where
  each = traversalVL $ \f ~(a,b) -> (,) <$> f a <*> f b
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a) (b,b,b) a b@
instance (a~a2, a~a3, b~b2, b~b3) => Each (a,a2,a3) (b,b2,b3) a b where
  each = traversalVL $ \f ~(a,b,c) -> (,,) <$> f a <*> f b <*> f c
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a) (b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, b~b2, b~b3, b~b4) => Each (a,a2,a3,a4) (b,b2,b3,b4) a b where
  each = traversalVL $ \f ~(a,b,c,d) -> (,,,) <$> f a <*> f b <*> f c <*> f d
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a,a) (b,b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, a~a5, b~b2, b~b3, b~b4, b~b5) => Each (a,a2,a3,a4,a5) (b,b2,b3,b4,b5) a b where
  each = traversalVL $ \f ~(a,b,c,d,e) -> (,,,,) <$> f a <*> f b <*> f c <*> f d <*> f e
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a,a,a) (b,b,b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, a~a5, a~a6, b~b2, b~b3, b~b4, b~b5, b~b6) => Each (a,a2,a3,a4,a5,a6) (b,b2,b3,b4,b5,b6) a b where
  each = traversalVL $ \f ~(a,b,c,d,e,g) -> (,,,,,) <$> f a <*> f b <*> f c <*> f d <*> f e <*> f g
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a,a,a,a) (b,b,b,b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, a~a5, a~a6, a~a7, b~b2, b~b3, b~b4, b~b5, b~b6, b~b7) => Each (a,a2,a3,a4,a5,a6,a7) (b,b2,b3,b4,b5,b6,b7) a b where
  each = traversalVL $ \f ~(a,b,c,d,e,g,h) -> (,,,,,,) <$> f a <*> f b <*> f c <*> f d <*> f e <*> f g <*> f h
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a,a,a,a,a) (b,b,b,b,b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, a~a5, a~a6, a~a7, a~a8, b~b2, b~b3, b~b4, b~b5, b~b6, b~b7, b~b8) => Each (a,a2,a3,a4,a5,a6,a7,a8) (b,b2,b3,b4,b5,b6,b7,b8) a b where
  each = traversalVL $ \f ~(a,b,c,d,e,g,h,i) -> (,,,,,,,) <$> f a <*> f b <*> f c <*> f d <*> f e <*> f g <*> f h <*> f i
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i (a,a,a,a,a,a,a,a,a) (b,b,b,b,b,b,b,b,b) a b@
instance (a~a2, a~a3, a~a4, a~a5, a~a6, a~a7, a~a8, a~a9, b~b2, b~b3, b~b4, b~b5, b~b6, b~b7, b~b8, b~b9) => Each (a,a2,a3,a4,a5,a6,a7,a8,a9) (b,b2,b3,b4,b5,b6,b7,b8,b9) a b where
  each = traversalVL $ \f ~(a,b,c,d,e,g,h,i,j) -> (,,,,,,,,) <$> f a <*> f b <*> f c <*> f d <*> f e <*> f g <*> f h <*> f i <*> f j
  {-# INLINE each #-}

-- | @'each' :: ('RealFloat' a, 'RealFloat' b) => 'Traversal' i ('Complex' a)
-- ('Complex' b) a b@
instance Each (Complex a) (Complex b) a b where
  each = traversalVL $ \f (a :+ b) -> (:+) <$> f a <*> f b
  {-# INLINE each #-}

-- | @'each' :: 'Traversal' i ('Map' c a) ('Map' c b) a b@
instance (c ~ d) => Each (Map c a) (Map d b) a b

-- | @'each' :: 'Traversal' i ('Map' c a) ('Map' c b) a b@
instance Each (IntMap a) (IntMap b) a b

-- | @'each' :: 'Traversal' i [a] [b] a b@
instance Each [a] [b] a b

-- | @'each' :: 'Traversal' i (NonEmpty a) (NonEmpty b) a b@
instance Each (NonEmpty a) (NonEmpty b) a b

-- | @'each' :: 'Traversal' i ('Identity' a) ('Identity' b) a b@
instance Each (Identity a) (Identity b) a b

-- | @'each' :: 'Traversal' i ('Maybe' a) ('Maybe' b) a b@
instance Each (Maybe a) (Maybe b) a b

-- | @'each' :: 'Traversal' i ('Seq' a) ('Seq' b) a b@
instance Each (Seq a) (Seq b) a b

-- | @'each' :: 'Traversal' i ('Tree' a) ('Tree' b) a b@
instance Each (Tree a) (Tree b) a b

-- | @'each' :: 'Ix' i => 'Traversal' i ('Array' i a) ('Array' i b) a b@
instance (Ix i, i ~ j) => Each (Array i a) (Array j b) a b where
  each = traversalVL $ \f arr ->
    array (bounds arr) <$> traverse (\(i,a) -> (,) i <$> f a) (IArray.assocs arr)
  {-# INLINE each #-}

-- | @'each' :: ('Ix' i, 'IArray' 'UArray' a, 'IArray' 'UArray' b) =>
-- 'Traversal' i ('Array' i a) ('Array' i b) a b@
instance (Ix i, IArray UArray a, IArray UArray b, i ~ j) => Each (UArray i a) (UArray j b) a b where
  each = traversalVL $ \f arr ->
    array (bounds arr) <$> traverse (\(i,a) -> (,) i <$> f a) (IArray.assocs arr)
  {-# INLINE each #-}

-- $setup
-- >>> import Optics
-- >>> import Optics.Operators
