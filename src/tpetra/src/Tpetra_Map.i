// Dependencies
%include "Teuchos_RCP.i"
%import <std_string.i>
%import <Teuchos_ArrayView.i>
%import <Teuchos_Comm.i>

%{
#include "Teuchos_RCP.hpp"
#include "Tpetra_Map.hpp"
%}

// =======================================================================
// Ignore permanently
// =======================================================================
%ignore Tpetra::Map::getNode;
// Ignore the Node versions
%ignore Tpetra::Map::Map(global_size_t numGlobalElements,
         GlobalOrdinal indexBase,
         const Teuchos::RCP<const Teuchos::Comm<int> > &comm,
         LocalGlobal lg,
         const Teuchos::RCP<Node> &node);
%ignore Tpetra::Map::Map(global_size_t numGlobalElements,
         size_t numLocalElements,
         GlobalOrdinal indexBase,
         const Teuchos::RCP<const Teuchos::Comm<int> > &comm,
         const Teuchos::RCP<Node> &node);
%ignore Tpetra::Map::Map(const global_size_t numGlobalElements,
         const Teuchos::ArrayView<const GlobalOrdinal>& indexList,
         const GlobalOrdinal indexBase,
         const Teuchos::RCP<const Teuchos::Comm<int> >& comm,
         const Teuchos::RCP<Node>& node);
%ignore Tpetra::Map::Map(const global_size_t numGlobalElements, const GlobalOrdinal indexList[],
         const LocalOrdinal indexListSize, const GlobalOrdinal indexBase,
         const Teuchos::RCP< const Teuchos::Comm< int > > &comm);

// =======================================================================
// Postpone temporarily
// =======================================================================
%ignore Tpetra::Map::Map(const global_size_t numGlobalElements,
         const Kokkos::View<const GlobalOrdinal*, device_type>& indexList,
         const GlobalOrdinal indexBase,
         const Teuchos::RCP<const Teuchos::Comm<int> >& comm); // needs Kokkos::View
%ignore Tpetra::Map::describe;                  // needs Teuchos::FancyOStream
%ignore Tpetra::Map::getLocalMap;               // no need to expose this yet
%ignore Tpetra::Map::getMyGlobalIndices;        // return type is not exposed externally, requires using `auto`

// =======================================================================
// Fix ±1 issues
// =======================================================================
%typemap(in)  int localIndex        %{$1 = *$input - 1;%}
%typemap(out) int getMinLocalIndex  %{$result = $1 + 1;%}
%typemap(out) int getMaxLocalIndex  %{$result = $1 + 1;%}
%typemap(out) int getLocalElement   %{$result = $1 + 1;%}
%typemap(argout) const Teuchos::ArrayView<int>& nodeIDList %{
  for (int i = 0; i < $1->size(); i++)
    (*$1)[i]++;
%}
%typemap(argout) const Teuchos::ArrayView<int>& LIDList %{
  for (int i = 0; i < $1->size(); i++)
    (*$1)[i]++;
%}


// =======================================================================
// Make interface more Fortran friendly
// =======================================================================
%ignore Tpetra::Map::Map(const global_size_t numGlobalElements, const Teuchos::ArrayView< const GlobalOrdinal > &indexList, const GlobalOrdinal indexBase, const Teuchos::RCP< const Teuchos::Comm< int > > &comm);
%ignore Tpetra::Map::getRemoteIndexList (const Teuchos::ArrayView< const GlobalOrdinal > &GIDList, const Teuchos::ArrayView< int > &nodeIDList, const Teuchos::ArrayView< LocalOrdinal > &LIDList) const;
%ignore getRemoteIndexList (const Teuchos::ArrayView< const GlobalOrdinal > &GIDList, const Teuchos::ArrayView< int > &nodeIDList) const;
%extend Tpetra::Map<int, long long, Kokkos::Compat::KokkosSerialWrapperNode> {
    Map(const global_size_t numGlobalElements, std::pair<const GO*,size_t> indexList, const GO indexBase, const Teuchos::RCP< const Teuchos::Comm< int > > &comm) {
      Teuchos::ArrayView<const GO> indexListView = Teuchos::arrayView(indexList.first, indexList.second);
      return new Tpetra::Map<LO,GO,NO>(numGlobalElements, indexListView, indexBase, comm);
    }
    LookupStatus getRemoteIndexList(std::pair<const GO*, size_t> GIDList, std::pair<int*, size_t> nodeIDList, std::pair<LO*, size_t> LIDList) const {
      Teuchos::ArrayView<const GO> GIDListView  = Teuchos::arrayView(GIDList.first, GIDList.second);
      Teuchos::ArrayView<int>  nodeIDListView   = Teuchos::arrayView(nodeIDList.first, nodeIDList.second);
      Teuchos::ArrayView<LO> LIDListView        = Teuchos::arrayView(LIDList.first, LIDList.second);

      return self->getRemoteIndexList(GIDListView, nodeIDListView, LIDListView);
    }
    LookupStatus getRemoteIndexList(std::pair<const GO*, size_t> GIDList, std::pair<int*, size_t> nodeIDList) const {
      Teuchos::ArrayView<const GO> GIDListView  = Teuchos::arrayView(GIDList.first, GIDList.second);
      Teuchos::ArrayView<int>  nodeIDListView   = Teuchos::arrayView(nodeIDList.first, nodeIDList.second);

      return self->getRemoteIndexList(GIDListView, nodeIDListView);
    }
}

// FIXME: figure out why the first verion does not work
/* %teuchos_rcp(Tpetra::Map<LO,GO,NO>); */
%teuchos_rcp(Tpetra::Map<int, long long, Kokkos::Compat::KokkosSerialWrapperNode>)

#define HAVE_TPETRA_INST_INT_INT
%include "Tpetra_ConfigDefs.hpp"
%include "Tpetra_Map_decl.hpp"

// FIXME: figure out why the first verion does not work
/* %template(TpetraMap) Tpetra::Map<LO,GO,NO>; */
%template(TpetraMap) Tpetra::Map<int, long long, Kokkos::Compat::KokkosSerialWrapperNode>;