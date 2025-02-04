module Dynamic.Helper where

import GHC.Stack

import Dynamic.Env
import Data.Map (Map)
import qualified Data.Map as Map

import Data.Set (Set)
import qualified Data.Set as Set

import Unbound.Generics.LocallyNameless
import Control.Monad.Except

import Control.Monad.Identity
import StdLib (n, s, nat, add, rep, head, stdlib)

import PreludeHelper
import SourcePos
import Dynamic.Err

runC :: WithSourceLocMT (WithModuleMT (FreshMT (ExceptT e Identity))) a
  -> Module -> Maybe SourceRange -> Either e a
runC e modul s = runIdentity $ runExceptT $ runFreshMT $ runWithModuleMT (runWithSourceLocMT e s ) modul


runCIo :: HasCallStack => Module ->  WithSourceLocMT (WithModuleMT (FreshMT (ExceptT Err Identity))) a
  -> IO a
runCIo modul e  = do
  let res = runC e modul Nothing
  case res of
    Right a -> pure a
    Left e -> errIo $ prettyErr e 